# CLAUDE.md — Finwaze

Shared project context and conventions for AI-assisted development. Client-specific rules live in
nested files that load when working in that folder:

- `src/CLAUDE.md` — Angular web client
- `ios/CLAUDE.md` — native iOS client

**Where a nested file disagrees with this one about client-specific matters, the nested file wins.**
Database and domain rules below apply to every client.

---

## Project Overview

A personal home finance tracking application. Users record transactions (income, expenses, transfers, balance adjustments), manage budgets, and track savings goals across multiple accounts and currencies.

**Backend:** PostgreSQL via local Supabase (`supabase/`) — shared by all clients  
**Clients:** Angular web app (`src/`), native iOS app (`ios/`)  

## Repository Layout

- `supabase/` — schemas, migrations, seeds. The RPC functions in `supabase/schemas/*.sql` are the API contract for every client.
- `src/` — Angular web client (see `src/CLAUDE.md`).
- `ios/` — native iOS client (see `ios/CLAUDE.md`).

### Multi-client compatibility

Released iOS builds stay on users' devices for months, while the web app updates instantly. Keep RPC and schema changes **backwards compatible**: never rename or remove an RPC function, parameter or returned column that a released client may use — add new parameters with a `DEFAULT`, or add a new function and deprecate the old one.

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

## Database: Tooling

- Load the **`supabase-postgres-best-practices`** skill before writing or changing anything that
  lives in Postgres — tables, columns, RLS policies, indexes, triggers, functions — and the
  **`supabase`** skill for any other Supabase-related task (CLI, Auth, Storage, Realtime, debugging).
- The **`supabase` MCP server** is available for the local instance. Use its read/inspection tools
  (`list_tables`, `execute_sql`, `get_advisors`, `query_logs`, `list_migrations`, `search_docs`, …)
  freely to explore schema and debug. `apply_migration` is also exposed by this server, but
  **Critical Rule 1 still applies** — never invoke it (and never run a migration via shell) unless
  the user explicitly asks.

## Database: Coding Rules

- **Money:** always `NUMERIC`, never `FLOAT`.
- **Timestamps:** always `TIMESTAMPTZ`.
- **Enum casts:** always explicit — `'income'::public.transaction_type`, never plain `'income'`.
- **Functions:** set `search_path = ''` and qualify all identifiers (`public.`, `auth.`). Mark read-only functions `STABLE`. Prefer `SECURITY INVOKER`.
- **Aggregates:** use `FILTER (WHERE ...)` instead of `CASE WHEN` inside aggregate functions.
- **RLS:** all tables have RLS enabled and scoped to `auth.uid()`. Keep it that way. Do not manually filter by `auth.uid()` inside functions — RLS enforces row-level access automatically. Redundant `WHERE user_id = auth.uid()` checks are noise and can mask policy bugs.
- **Schema changes:** always read the relevant migration files before suggesting schema modifications — the schema evolves actively.
- **SQL functions:** when creating or modifying a SQL function, write the change to the appropriate `supabase/schemas/*.sql` file — never create a migration file for function changes.

---

## Client Data Contract

These rules apply to every client (web and iOS):

- Parameter names must match the SQL function parameter names exactly (including the `p_` prefix).
- Send `DATE` parameters as ISO strings in `YYYY-MM-DD` format.
- For `p_local_offset`, send a PostgreSQL interval string, e.g., `'+02:00'`.
- When displaying dates, always apply `local_offset` before formatting.
- Currency amounts must always be displayed with their currency code or symbol.
- Never expose system records (`is_system = true`) in the UI.

---

## Local Development

```bash
supabase start   # start local Supabase
```

Client-specific commands (install, run, test, lint, build) are in `src/CLAUDE.md` and `ios/CLAUDE.md`.

### Demo data

A demo user (`demo@mail.com` / `password1234`) is seeded with 4 accounts (USD, UAH, EUR, CZK), 12 expense groups and 2 income groups with ~100 categories.

---

## Git Commits

Follow the `git-commits` skill. Project-specific scopes:

`wallet`, `transactions`, `budget`, `dashboard`, `analytics`, `goals`, `groups`, `auth`, `core`, `shared`, `db`, `seed`, `ios`

### Other rules

- **Never add `Co-Authored-By` trailers.**
- **Always sign commits with GPG.**

---

## Critical Rules (do not violate)

Client-specific critical rules are in `src/CLAUDE.md` and `ios/CLAUDE.md`.

1. **Do not apply or run migrations after writing SQL** — after creating or modifying a SQL function or schema file, stop. Never attempt to apply, run, or execute a migration unless the user explicitly asks.
2. **Do not create migration files for SQL functions** — function changes go into the appropriate `supabase/schemas/*.sql` file (e.g. `charts_funcs.sql`, `transactions_funcs.sql`). Migration files are only for schema changes (tables, columns, indexes, enums).
3. **Do not use `type` to distinguish income from expense in aggregations** — use the sign of the amount (negative = expense, positive = income). Use `type` only to exclude `transfer` and `internal` rows.
4. **Do not use raw `transacted_at` for date grouping** — always use `(transacted_at + local_offset)`.
5. **Do not use `FLOAT` for money** — always `NUMERIC`.
6. **Do not unqualify identifiers in functions** — always prefix with `public.` / `auth.` and set `search_path = ''`.
7. **Do not expose system records (`is_system = true`) in the UI** — filter them out at the query level.
8. **Do not forget enum casts** — `'income'::public.transaction_type`, not just `'income'`.
9. **Do not break released clients** — RPC/schema changes must stay backwards compatible (see Multi-client compatibility).

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
