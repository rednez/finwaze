# CLAUDE.md — Finwaze Web (Angular)

Angular-specific conventions for the web client in `src/`. Shared backend, database and domain
rules live in the root `../CLAUDE.md` — read it too.
This file complements the `angular-developer` skill and `.github/copilot-instructions.md` (the official
Angular v22 best-practices baseline) — read all of them before making changes.
**Where this file disagrees with the generic baseline, this file wins.**

### Tooling

- Load the **`angular-developer`** skill before generating components, services, forms, routing, or
  giving reactivity/testing/styling guidance — it complements the rules below.
- The **`angular-cli` MCP server** is available for this workspace. Prefer it over raw shell
  commands for equivalent actions: call `list_projects` first to discover the workspace, then
  `get_best_practices` before writing or modifying code, and `search_documentation` for conceptual
  or API syntax questions instead of answering from memory.

---

## Stack

**Frontend:** Angular 22 (zoneless), TypeScript 6, Tailwind CSS 4, OptimusNG 2, NgRx SignalStore 22  
**Testing:** Vitest (via `@angular/build:unit-test`)  
**Package manager:** PNPM  

---

## Project Layout

Source code lives in `src/app/`. Features are self-contained under `features/<feature>/` with their own `models/`, `repositories/`, `mappers/`, `stores/`, `pages/`, `ui/` and `routes.ts`. Cross-feature code lives in `core/` (services, stores, guards, layout, models, mappers, repositories, i18n) and `shared/` (`ui/`, `pipes/`, `utils/`). Database schemas, migrations and seed data are in `supabase/` (repo root).

### Path aliases

Imports use TS path aliases, never deep relative paths across feature boundaries:

`@core/services/*`, `@core/store/*`, `@core/layout/*`, `@core/models/*`, `@core/mappers/*`, `@core/repositories/*`, `@core/utils/*`, `@core/guards`, `@core/configs`, `@core/i18n`, `@shared/ui/*`, `@shared/pipes/*`, `@shared/utils/*`, `@env`

There is no `baseUrl` in `tsconfig.json` — every `paths` target must be written relative to the config file (`./src/app/...`).

---

## Frontend: Architecture

### Angular 22 essentials

The app runs **zoneless** — `zone.js` is not a dependency. Change detection is driven by signals; never rely on zone patching to pick up async updates.

- **Do not set `changeDetection: ChangeDetectionStrategy.OnPush`** — `OnPush` is the default in v22. There should be no `ChangeDetectionStrategy` import anywhere in `src/`.
- **Do not set `standalone: true`** — standalone is the default; NgModules are not used.
- Use `input()` / `output()` / `model()` functions, never `@Input()` / `@Output()` decorators.
- Use `computed()` for derived state and `linkedSignal()` for state derived from reactive sources that must stay in sync.
- Put host bindings in the `host` object of `@Component` / `@Directive` — never `@HostBinding` / `@HostListener`.
- Use native control flow (`@if`, `@for`, `@switch`), never `*ngIf` / `*ngFor` / `*ngSwitch`.
- Bind with `[class.x]` / `[style.x]`, never `ngClass` / `ngStyle`.
- Use `inject()`, never constructor injection.
- Use `update()` / `set()` on signals, never `mutate()`.
- Feature routes are lazy-loaded via `loadComponent` / `loadChildren` — keep it that way for new routes.
- Templates cannot use arrow functions, and the only supported globals are `undefined` and `$any` — no `new Date()`, `Math`, `JSON`, etc. Move that logic into a `computed()` or the store.
- Use `NgOptimizedImage` for any static raster image added later. The app currently ships zero `<img>` tags — logos are inline SVG components under `core/layout/sidebar/logo/`.
- Prefer inline templates for small components; larger ones use a sibling `.html` file referenced by a path relative to the component `.ts`.

### Services: `@Service`

New singleton services, repositories and mappers use the v22 **`@Service()`** decorator, not `@Injectable({ providedIn: 'root' })`:

```typescript
import { inject, Service } from '@angular/core';

@Service()
export class BudgetRepository {
  private readonly supabase = inject(SupabaseService);
}
```

The existing ~53 classes are still on `@Injectable({ providedIn: 'root' })` and are being converted wholesale in a dedicated commit — until that lands, do not convert files opportunistically as part of unrelated work. Use `@Injectable` only where a non-root provider scope is genuinely needed.

### Forms

New forms use **Signal Forms** (`@angular/forms/signals`), stable in v22 — signal-based state, type-safe field access, schema-based validation:

```typescript
import { email, form, required } from '@angular/forms/signals';

protected readonly model = signal({ email: '' });
protected readonly loginForm = form(this.model, (p) => {
  required(p.email);
  email(p.email);
});
```

The 20 existing `FormBuilder` + `ReactiveFormsModule` forms stay as they are — do not rewrite them opportunistically. When touching an existing Reactive Form, keep it Reactive; do not mix the two systems within one component. Template-driven forms are not used at all.

### State Management

State is managed exclusively with **NgRx SignalStore v22** (`@ngrx/signals` 22). No `@ngrx/store`,
`@ngrx/effects`, `@ngrx/entity` or `@ngrx/operators` are installed — do not introduce actions,
reducers, selectors or `tapResponse` patterns.

- Store files are named `<feature>-store.ts` (e.g. `transactions-store.ts`).
- Store lives at the level where it's needed — at sub-feature level if used by one, at feature level if shared across multiple sub-features.
- Do not put business logic in components — delegate to the store.
- Stores are built from `signalStore` + `withState` / `withComputed` / `withMethods` / `withProps` /
  `withHooks`, with `patchState` for updates. Most stores are app-wide
  (`signalStore({ providedIn: 'root' }, …)`); short-lived ones are listed in the owning component's
  `providers: [...]` (e.g. `CreateBudgetStore`, `BudgetsByGroupStore`).
- Async work lives in `withMethods` as plain `async` methods calling a repository — `rxMethod` and
  RxJS are not used for store side effects.

#### v22: deep signals for nullable object slices

Since v22, a state slice (or `deepComputed` result) whose type is a union containing an object type
exposes a **`DeepSignal` per object member** instead of one `Signal` over the whole union:

```ts
// state: { transaction: Transaction | null }
store.transaction; // DeepSignal<Transaction> | Signal<null>   (was Signal<Transaction | null>)
store.transaction(); // still Transaction | null — call, then narrow
```

- Call the signal and narrow the result (`const t = store.transaction(); if (!t) return;`) — that
  pattern is unaffected and is what every existing store does.
- **Do not type such a slice as `Signal<T | null>`** — it is no longer assignable. Inside a generic
  `signalStoreFeature`, use `DeepSignalOf<T | null>` from `@ngrx/signals`.
- Affected slices today: `AuthStore.user`, `SelectedTransactionStore.transaction`,
  `IncomeTransactionStore.selectedTransaction`, `AnalyticsStore.financialSummary`,
  `BudgetStore.selectedGroup`. Primitive unions (`string | null`, `number | null`, `Date | null`)
  are unchanged.

#### v22: available but unused

`@ngrx/signals/resource` (`extendResource`, `withValueOnError`, `withPreviousValueOnLoading`, …) and
`@ngrx/signals/events` ship with v22 but are not used here. Data loading goes through repositories
called from store methods — do not introduce the resource or events APIs without a deliberate decision.

### Data access: repositories and mappers

- All Supabase calls go through **repositories**, not components or stores: `features/<feature>/repositories/<feature>-repository.ts` (shared ones in `core/repositories/`).
- A repository injects `SupabaseService` and calls `this.supabase.client.rpc(...)`; new ones are decorated with `@Service()` (see above).
- Repository methods are `async` and return `Promise<Model>` — they throw `new Error(error.message)` on a Supabase error rather than returning it.
- Raw DB rows (`*Dto` types) are converted to domain models by a **mapper** (`features/<feature>/mappers/<feature>-mapper.ts`). Repositories return mapped models, never DTOs.
- Stores call repositories; components call stores.
- A few `*.service.ts` files remain in `core/services/` (`supabase.service.ts`, `theme.service.ts`, `localization.service.ts`, `auth-service.ts`) — these are app-level concerns, not data access.

### Accessibility

- Markup must pass AXE checks and meet WCAG AA minimums — focus management, colour contrast, ARIA attributes.
- `angular-eslint`'s template-accessibility ruleset is enabled in `eslint.config.js`; `pnpm lint` enforces it.

### v22 migration debt

`ng update` left artefacts that should be paid down, not copied into new code:

- **`$safeNavigationMigration(...)`** — 12 call sites across `group-card.html`, `edit-goal.html`, `account-settings.html`, `create-budget-group-row.ts`. In v22 `?.` follows standard JS semantics (returns `undefined`, not `null`); this shim preserves the old null-returning behaviour. It is a temporary compiler aid, may be removed by Angular, and **must not be used in new code** — write plain `?.` and handle `undefined`.
- **Suppressed extended diagnostics** in `tsconfig.app.json` (`nullishCoalescingNotNullable`, `optionalChainNotNullable`) — added to silence the migration. Re-enable once the `?.` usages are cleaned up.

### UI / Styling

The UI library is **OptimusNG** (`@openng/optimus-ui`) — a community-maintained, MIT-licensed
suite of 80+ accessible Angular components.

Reference docs for AI assistants: <https://optimus.openng.org/llms/llms.txt> (index of guides and
components) — full single-file text at <https://optimus.openng.org/llms/llms-full.txt>.
Fetch these instead of answering from memory when working with OptimusNG APIs.

- Use **OptimusNG** components for all UI elements (tables, dialogs, selects, date pickers, etc.).
- Import from the per-component secondary entry point, never the package root:
  `import { ButtonModule } from '@openng/optimus-ui/button';`
- `MessageService` / `ConfirmationService` are imported from `@openng/optimus-ui/api`.
- Selectors keep the `p-` prefix (`<p-button>`, `<p-select>`); directives too (`pTooltip`).
- Icons come from **OpenNG Icons** (`@openng/icons`), used via `pi pi-*` classes. The stylesheet is
  imported in `src/styles.css`.
- Theming is configured with `provideOptimus()` from `@openng/optimus-ui/config` in `app.config.ts`;
  the preset is built with `definePreset(Aura, …)` from `@openng/optimus-ui-themes` in
  `src/app/custom-theme.ts`. Design-token types live under `@openng/optimus-ui-themes/types/<component>`.
- Dark mode uses `darkModeSelector: '.dark'`, matched by the `@custom-variant dark` rule in
  `src/styles.css`.
- Tailwind integration comes from `@openng/optimus-ui-tailwindcss`, imported in `src/styles.css`.
- Use **Tailwind** utility classes for layout and spacing; avoid custom CSS unless unavoidable.
- Do not create custom form controls when an OptimusNG equivalent exists.
- Currency amounts must always be displayed with their currency code or symbol.

### Naming conventions

| Entity           | Convention                          | Example                   |
|------------------|-------------------------------------|---------------------------|
| Component (file) | `kebab-case.ts`                     | `transaction-list.ts`     |
| Component (class)| `PascalCase`, no `Component` suffix | `TransactionList`         |
| Store (file)     | `kebab-case-store.ts`               | `transactions-store.ts`   |
| Repository (file)| `kebab-case-repository.ts`          | `budget-repository.ts`    |
| Mapper (file)    | `kebab-case-mapper.ts`              | `budget-mapper.ts`        |
| Service (file)   | `kebab-case.service.ts`             | `supabase.service.ts`     |
| Signal           | `camelCase`, no `$` suffix          | `selectedMonth`           |
| Computed         | Descriptive noun phrase             | `filteredTransactions`    |

---

## Frontend: Data Access Patterns

### Calling PostgreSQL functions from Angular

Inside a repository, use the Supabase client's `.rpc()` method:

```typescript
@Service()
export class TransactionsRepository {
  private readonly supabase = inject(SupabaseService);
  private readonly mapper = inject(TransactionsMapper);

  async getFilteredTransactions(month: Date): Promise<Transaction[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_filtered_transactions', {
        p_month: dayjs(month).format('YYYY-MM-DD'),
        p_page: 1,
        p_page_size: 20,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return this.mapper.toTransactions(data);
  }
}
```

Parameter names must match the SQL function parameter names exactly (including the `p_` prefix).

---

## Testing

- Framework: **Vitest**, run through the Angular `@angular/build:unit-test` builder (`pnpm test`, not the `vitest` binary)
- `describe` / `it` / `expect` / `vi` are available as globals — do not import them from `vitest`
- Test files: `*.spec.ts`, co-located with the file under test
- Use `TestBed.configureTestingModule({ providers: [...] })` + `TestBed.inject(...)`; mock `SupabaseService` with a fake `client.rpc`
- Test stores, repositories and mappers in isolation
- Do not test SQL logic in unit tests — cover DB functions with integration/e2e tests against local Supabase

---

## Local Development

Run from the repo root:

```bash
pnpm install   # install dependencies
pnpm start     # run the app
pnpm test      # unit tests
pnpm lint      # ESLint 10 flat config, angular-eslint + @ngrx/eslint-plugin 22
pnpm build     # production build
```

---

## Critical Rules (do not violate)

Database rules (migrations, `local_offset`, `NUMERIC`, system records, enum casts, …) are in the root `../CLAUDE.md`.

1. **Do not add `changeDetection: ChangeDetectionStrategy.OnPush` or `standalone: true`** — both are Angular v22 defaults. Adding them is dead code and will be flagged.
2. **Do not introduce `zone.js` or zone-dependent APIs** — the app is zoneless; reactivity flows through signals.
3. **Do not call Supabase from a component or store** — go through a repository, which returns mapped domain models.
4. **Do not use `@Injectable({ providedIn: 'root' })` in new code** — use `@Service()` (v22). Do not convert existing services as a side effect of unrelated work.
5. **Do not build new forms with `FormBuilder`** — use Signal Forms. Do not rewrite existing Reactive Forms opportunistically, and never mix both in one component.
6. **Do not add new `$safeNavigationMigration(...)` calls** — it is a temporary v22 migration shim; use plain `?.` with `undefined` handling.
7. **Do not source UI APIs from PrimeNG** — OptimusNG mirrors PrimeNG's `p-` selectors, `pi pi-*` icons and `definePreset` theming, but the APIs diverge. Never import from `primeng/*`, and never use PrimeNG docs, MCP tools or skills as a source of truth.
8. **Do not import the ESLint plugin from `@ngrx/eslint-plugin/v9`** — that subpath was removed in v22. Require it from the package root (`require('@ngrx/eslint-plugin')`) in the flat config; ESLint v8 / `.eslintrc` is no longer supported.
9. **Do not type a nullable object state slice as `Signal<T | null>`** — in v22 it is `DeepSignal<T> | Signal<null>`. Call the signal and narrow, or use `DeepSignalOf<T | null>` in generic store features.
