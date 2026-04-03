# CLAUDE.md — Finwaze

This file provides project-specific context and conventions for AI-assisted development.
It complements the `angular-expert` skill — read both before making changes.

---

## Project Overview

A personal home finance tracking application. Users record transactions (income, expenses, transfers, balance adjustments), manage budgets, and track savings goals across multiple accounts and currencies.

**Backend:** PostgreSQL via local Supabase  
**Frontend:** Angular 21, Tailwind CSS, PrimeNG, NgRx SignalStore  
**Testing:** Vitest  
**Package manager:** PNPM  

---

## Project Layout

Source code lives in `src/app/`. Features are self-contained under `features/<feature>/` with their own models, repositories, stores, and UI components. Shared components are in `shared/ui/`. Database migrations and seed data are in `supabase/`.

---

## Database: Key Concepts

### Transaction types

Four types exist: `income`, `expense`, `transfer`, `internal`. Only `income` and `expense` are included in aggregations and summaries — `transfer` and `internal` must always be excluded.

Filter by type semantically, not by the sign of the amount. Use opt-out style for forward compatibility:

```sql
WHERE t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
```

### Local time

Transactions store a `local_offset` interval (the user's UTC offset). Always apply it when filtering or grouping by date: `(transacted_at + local_offset)`. Never use raw `transacted_at`.

### System records

Groups and categories with `is_system = true` are reserved for internal use (transfers, balance adjustments). Never expose them in the UI, modify, or delete them.

---

## Database: Coding Rules

- **Money:** always `NUMERIC`, never `FLOAT`.
- **Timestamps:** always `TIMESTAMPTZ`.
- **Enum casts:** always explicit — `'income'::public.transaction_type`, never plain `'income'`.
- **Functions:** set `search_path = ''` and qualify all identifiers (`public.`, `auth.`). Mark read-only functions `STABLE`. Prefer `SECURITY INVOKER`.
- **Aggregates:** use `FILTER (WHERE ...)` instead of `CASE WHEN` inside aggregate functions.
- **RLS:** all tables have RLS enabled and scoped to `auth.uid()`. Keep it that way. Do not manually filter by `auth.uid()` inside functions — RLS enforces row-level access automatically. Redundant `WHERE user_id = auth.uid()` checks are noise and can mask policy bugs.
- **Schema changes:** always read the relevant migration files before suggesting schema modifications — the schema evolves actively.

---

## Frontend: Architecture

### State Management

- Store files are named `<feature>-store.ts` (e.g. `transactions-store.ts`).
- Store lives at the level where it's needed — at sub-feature level if used by one, at feature level if shared across multiple sub-features.
- Do not put business logic in components — delegate to the store.

### Services

- Supabase client calls live in dedicated service files (`<feature>.service.ts`), co-located with the feature or sub-feature they belong to.
- Services return `Observable` or `Promise` — prefer `Observable` for consistency with NgRx patterns.
- One service per feature domain.

### UI / Styling

- Use **PrimeNG** components for all UI elements (tables, dialogs, dropdowns, date pickers, etc.)
- Use **Tailwind** utility classes for layout and spacing; avoid custom CSS unless unavoidable.
- Do not create custom form controls when a PrimeNG equivalent exists.
- Currency amounts must always be displayed with their currency code or symbol.

### Naming conventions

| Entity           | Convention                          | Example                   |
|------------------|-------------------------------------|---------------------------|
| Component (file) | `kebab-case.ts`                     | `transaction-list.ts`     |
| Component (class)| `PascalCase`, no `Component` suffix | `TransactionList`         |
| Store (file)     | `kebab-case-store.ts`               | `transactions-store.ts`   |
| Service (file)   | `kebab-case.service.ts`             | `transactions.service.ts` |
| Signal           | `camelCase`, no `$` suffix          | `selectedMonth`           |
| Computed         | Descriptive noun phrase             | `filteredTransactions`    |

---

## Frontend: Data Access Patterns

### Calling PostgreSQL functions from Angular

Use the Supabase client's `.rpc()` method:

```typescript
const { data, error } = await this.supabase
  .rpc('get_filtered_transactions', {
    p_month: '2024-03-01',
    p_page: 1,
    p_page_size: 20,
  });
```

Parameter names must match the SQL function parameter names exactly (including the `p_` prefix).

### Date handling

- Always send dates to the backend as ISO strings in `YYYY-MM-DD` format for `DATE` parameters.
- For `p_local_offset`, send a PostgreSQL interval string, e.g., `'+02:00'`.
- When displaying dates in the UI, always apply `local_offset` before formatting.

---

## Testing

- Framework: **Vitest**
- Test files: `*.spec.ts`, co-located with the file under test
- Test stores and services in isolation using mocks for the Supabase client
- Do not test SQL logic in unit tests — cover DB functions with integration/e2e tests against local Supabase

---

## Local Development

```bash
# Install dependencies
pnpm install

# Start local Supabase
supabase start

# Run the app
pnpm start

# Run unit tests
pnpm test

# Run tests with UI
pnpm test:ui
```

### Demo data

A demo user (`demo@mail.com` / `password1234`) is seeded with 4 accounts (USD, UAH, EUR, CZK), 12 expense groups and 2 income groups with ~100 categories.

---

## Git Commits

Follow the `git-commits` skill. Project-specific scopes:

`wallet`, `transactions`, `budget`, `dashboard`, `analytics`, `goals`, `groups`, `auth`, `core`, `shared`, `db`, `seed`

### Other rules

- **Never add `Co-Authored-By` trailers.**
- **Always sign commits with GPG.**

---

## Critical Rules (do not violate)

1. **Do not apply or run migrations after writing SQL** — after creating or modifying a SQL function or schema file, stop. Never attempt to apply, run, or execute a migration unless the user explicitly asks.
2. **Do not use `type` to distinguish income from expense in aggregations** — use the sign of the amount (negative = expense, positive = income). Use `type` only to exclude `transfer` and `internal` rows.
3. **Do not use raw `transacted_at` for date grouping** — always use `(transacted_at + local_offset)`.
4. **Do not use `FLOAT` for money** — always `NUMERIC`.
5. **Do not unqualify identifiers in functions** — always prefix with `public.` / `auth.` and set `search_path = ''`.
6. **Do not expose system records (`is_system = true`) in the UI** — filter them out at the query level.
7. **Do not forget enum casts** — `'income'::public.transaction_type`, not just `'income'`.

---

## Domain Glossary

| Term                 | Meaning                                                                                     |
|----------------------|---------------------------------------------------------------------------------------------|
| Account              | A financial account (bank, cash, wallet). Type: `regular` or `savings_goal`                |
| Group                | Top-level categorisation of transactions (e.g., "Автомобіль", "Послуги")                   |
| Category             | Sub-item within a group (e.g., "Бензин" within "Автомобіль")                               |
| Transaction          | A single financial event linked to an account, category, and currency                       |
| Transfer             | A paired movement of funds between two accounts                                             |
| Internal             | A system-generated balance adjustment transaction                                           |
| `transaction_amount` | Amount in the currency the transaction was made in (e.g., 5 EUR for a purchase abroad)     |
| `charged_amount`     | Amount debited from the account in its own currency (e.g., 200 UAH for that same 5 EUR)    |
| `local_offset`       | The user's UTC offset stored as a PostgreSQL INTERVAL                                       |
| Budget               | A planned spending amount per category per month                                            |
| Savings Goal         | A target amount linked to a dedicated savings account                                       |
