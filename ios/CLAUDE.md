# CLAUDE.md — Finwaze iOS

Conventions for the native iOS client in `ios/`. Backend, database and domain rules (transaction
types, `local_offset`, system records, glossary, commit scopes) are in the root `../CLAUDE.md` —
read it first; it applies here in full.

The backend is the existing Supabase project in `../supabase/`. Read the SQL functions in
`../supabase/schemas/*.sql` to learn the exact RPC names, parameters and return columns before
writing any repository.

---

## Stack

**UI:** SwiftUI  
**Language:** Swift 6 (language mode 6 — strict concurrency)  
**State:** Observation framework (`@Observable`)  
**Backend SDK:** `supabase-swift` (added via Swift Package Manager)  
**Testing:** Swift Testing (`import Testing`)  

### Decisions

- **Minimum iOS:** 26.0 — the first version with Liquid Glass. Use the native Liquid Glass styling
  (system components, `glassEffect`) rather than custom blur/material imitations.
- **Bundle identifier:** `dev.yefimenko.Finwaze` for Release, `…Finwaze.staging` for Staging and `…Finwaze.dev` for Debug,
  so all three builds can sit side by side (tests: `dev.yefimenko.FinwazeTests`, `dev.yefimenko.FinwazeUITests`).
- **Localization:** English (`en`, development language and fallback), Ukrainian (`uk`), Czech (`cs`) —
  the same set as the web client. The app follows the OS language; if it is not supported, English is used.
- **Concurrency:** Swift 6 language mode with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. Mark
  non-UI code (DTOs, mappers, repositories) `nonisolated` / `Sendable` where needed.

Still open: whether to use `SwiftData` for an offline cache.

---

## Architecture

Mirrors the web client's layering, in Swift terms:

**View → ViewModel → Repository → Mapper → Supabase**

- Views are declarative and hold no business logic — delegate to the ViewModel.
- ViewModels are `@MainActor @Observable` classes; async work lives in plain `async` methods calling a repository.
- **All Supabase calls go through repositories** — never from a View or ViewModel.
- Repository methods are `async throws` and return mapped domain models, never DTOs. They throw on a Supabase error.
- Raw DB rows are `Decodable` `*Dto` types converted to domain models by a mapper.
- Inject dependencies through initializers (protocols for repositories) — no singletons except the shared `SupabaseClient` wrapper.
- Use `async`/`await` and structured concurrency; no Combine and no completion-handler APIs for new code.

### Layout

Group by feature, like the web app: `Features/<Feature>/{Models,Repositories,Mappers,ViewModels,Views}`,
with cross-feature code in `Core/` (auth, networking, i18n, extensions) and `Shared/` (reusable views).

### Demo mode

Demo mode (`AUTH-10`), like on the web, signs in to the shared server demo account (`demo@mail.com`) — a regular
session with email and avatar — but never reads or writes data on the server: it serves local data from
`Core/Demo/DemoData`. Repositories are picked in one place — `Repositories.live(client:)` or `Repositories.demo`,
exposed as `AppViewModel.repositories`. When a stage adds a repository:

- add it to both sets in `Core/Repositories/Repositories.swift`;
- give it a demo implementation next to `DemoReferenceDataRepository` that serves `DemoData`;
- make every write method in the demo implementation a no-op that succeeds without changing any data, so the demo
  always shows the same data.

### Calling PostgreSQL functions

```swift
struct TransactionsRepository {
    let client: SupabaseClient

    func filteredTransactions(month: Date) async throws -> [Transaction] {
        let dtos: [TransactionDto] = try await client
            .rpc("get_filtered_transactions", params: [
                "p_month": month.isoDateString,   // "YYYY-MM-DD"
                "p_page": 1,
                "p_page_size": 20,
            ])
            .execute()
            .value
        return dtos.map(TransactionMapper.toTransaction)
    }
}
```

Parameter names must match the SQL function parameter names exactly (including the `p_` prefix).

---

## Data & Formatting Rules

- **Money is `Decimal`, never `Double`/`Float`.** Decode `NUMERIC` values without losing precision.
- Always show amounts with their currency code or symbol, formatted with `FormatStyle` for the currency.
- Send dates to the backend as `YYYY-MM-DD` strings; send `p_local_offset` as an interval string like `'+02:00'` computed from the device's current `TimeZone`.
- When displaying a transaction date, apply its stored `local_offset` before formatting — do not rely on the device time zone.
- Filter out system records (`is_system = true`) at the query level.

---

## UI

- **Every screen follows Apple's [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
  (HIG) for iOS 26 and Liquid Glass.** When designing or changing UI, check the relevant HIG pages (layout,
  toolbars, menus, sheets, alerts, typography, colour) and prefer the system pattern over a custom one. If the
  functional design asks for something the HIG advises against, say so and propose the HIG-conforming alternative
  before building it (as `NAV-03` does for the "?" on iOS).
- Use native SwiftUI components and system styling; don't restyle system controls (fonts, weights, paddings) without a reason.
- Liquid Glass is the control layer — navigation bar, tab bar, floating controls; content (cards, lists) is never glass.
- Navigation bar: controls that act on the whole screen (e.g. the Dashboard currency) go in the toolbar, grouped by
  function — the section's actions in one group, the profile menu apart. Help goes into the "Help" menu ("…"), not
  the bar; secondary sections live in the "More" tab, never pushed onto another tab. The profile menu is only on a
  tab's root screen.
- Only irreversible actions — ones that delete data the user can't restore (delete, cancel a goal) — ask for
  confirmation (`confirmationDialog`). Reversible ones, such as signing out, run straight away.
- Check UI changes in the simulator (screenshots), not only by building — including neighbouring screens, so the
  navigation bar and menus stay consistent across sections.
- Support Dark Mode, Dynamic Type and VoiceOver from the start: label every control, don't hard-code font sizes or colours (use semantic colours / asset catalog).
- All user-facing strings go through a String Catalog (`Localizable.xcstrings`) — no hard-coded strings in Views.
- Keep Views small; extract subviews rather than growing `body`.

---

## Naming conventions

| Entity     | Convention                            | Example                    |
|------------|---------------------------------------|----------------------------|
| Type       | `PascalCase`                          | `TransactionListView`      |
| View       | `<Name>View`                          | `BudgetDetailView`         |
| ViewModel  | `<Name>ViewModel`                     | `TransactionsViewModel`    |
| Repository | `<Name>Repository`                    | `BudgetRepository`         |
| Mapper     | `<Name>Mapper`                        | `BudgetMapper`             |
| DTO        | `<Name>Dto`                           | `TransactionDto`           |
| Property   | `camelCase`                           | `selectedMonth`            |
| File       | Named after its primary type          | `BudgetRepository.swift`   |

---

## Testing

- Swift Testing (`@Test`, `#expect`); test ViewModels, repositories and mappers in isolation.
- Repositories depend on a protocol so tests can inject a fake — do not hit the network in unit tests.
- Do not test SQL logic here — DB functions are covered by integration tests against local Supabase.

---

## Local Development

Commands run from the repo root (paths are relative to it). Project `Finwaze.xcodeproj`.

### Environments

Like `src/environments/*` on the web, each build configuration talks to its own backend:

| Configuration | Scheme            | Backend                        | App name      |
|---------------|-------------------|--------------------------------|---------------|
| Debug         | `Finwaze`         | local Supabase (`supabase start`) | Finwaze Dev |
| Staging       | `Finwaze Staging` | hosted staging project         | Finwaze β     |
| Release       | `Finwaze` (archive) | hosted production project    | Finwaze       |

Values (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `WEB_APP_URL`, bundle id, display name) live in
`ios/Config/<Configuration>.xcconfig` and reach the app through `ios/Config/Info.plist`; `SupabaseConfig` reads them
from the bundle. These files are committed: they hold publishable keys only, the same ones the web client ships.

```bash
supabase start                                   # local backend (repo root)
xcodebuild -project ios/Finwaze.xcodeproj -scheme Finwaze \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' build
xcodebuild -project ios/Finwaze.xcodeproj -scheme Finwaze \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' test
```

Known unfinished work is tracked in `ios/docs/TECH_DEBT.md`.
Implementation plans for the stages of `docs/functional-design.md` (section 6) live next to it as
`ios/docs/STAGE_<N>_PLAN.md`; put a new stage's plan there too.
Demo user (`demo@mail.com` / `password1234`) is described in the root file.

---

## Critical Rules (do not violate)

Database rules are in the root `../CLAUDE.md`.

1. **Do not call Supabase from a View or ViewModel** — go through a repository that returns mapped domain models.
2. **Do not use `Double`/`Float` for money** — use `Decimal`.
3. **Do not rename or reshape backend RPCs from the iOS side** — the API is shared; changes must stay backwards compatible.
4. **Do not commit secrets** — publishable Supabase keys go into `ios/Config/*.xcconfig`; secret and `service_role`
   keys and signing material never enter git.
5. **Do not hard-code user-facing strings** — use the String Catalog.
6. **Do not introduce Combine or completion-handler APIs in new code** — use `async`/`await`.
7. **Do not let demo mode touch server data** — every repository has a demo implementation that serves local data and whose writes are no-ops.
8. **Do not build UI that departs from Apple's Human Interface Guidelines** — use system components and patterns; flag
   any conflict with the functional design instead of silently following either.
