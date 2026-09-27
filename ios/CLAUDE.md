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
- **Bundle identifier:** `dev.yefimenko.Finwaze` (tests: `dev.yefimenko.FinwazeTests`, `dev.yefimenko.FinwazeUITests`).
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

- Use native SwiftUI components and system styling; follow Apple Human Interface Guidelines.
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

Commands run from the repo root (paths are relative to it). Project `Finwaze.xcodeproj`, scheme `Finwaze`.

```bash
supabase start                                   # local backend (repo root)
xcodebuild -project ios/Finwaze.xcodeproj -scheme Finwaze \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' build
xcodebuild -project ios/Finwaze.xcodeproj -scheme Finwaze \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' test
```

The local Supabase URL and publishable key are read from the git-ignored `ios/Finwaze/Config/Supabase.plist`
(copy it from `ios/Supabase.example.plist`) — never commit keys.

Known unfinished work is tracked in `ios/TECH_DEBT.md`.
Demo user (`demo@mail.com` / `password1234`) is described in the root file.

---

## Critical Rules (do not violate)

Database rules are in the root `../CLAUDE.md`.

1. **Do not call Supabase from a View or ViewModel** — go through a repository that returns mapped domain models.
2. **Do not use `Double`/`Float` for money** — use `Decimal`.
3. **Do not rename or reshape backend RPCs from the iOS side** — the API is shared; changes must stay backwards compatible.
4. **Do not commit secrets** — Supabase keys and signing material stay out of git.
5. **Do not hard-code user-facing strings** — use the String Catalog.
6. **Do not introduce Combine or completion-handler APIs in new code** — use `async`/`await`.
