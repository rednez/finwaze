# iOS — План етапу 6 «Керування рахунками»

> **Статус:** не розпочато.

## Контекст

Етап 6 з `docs/functional-design.md` (розділ 6): **ACC-09…12**. Залежить від етапу 3 (етапи 4–5 уже готові).
Зараз картка рахунку в Гаманці нічого не відкриває (`WalletView.AccountCardGrid` — «stage 6»). Результат для
користувача: корекція балансу, перейменування, зміна валюти й видалення рахунку.

## Рішення

- **Схеми Supabase не змінюються.** Використовуємо те саме, що web (`wallet-repository.ts`,
  `wallet-accounts-store.ts`):
  - деталі — RPC `get_regular_account_with_balance(p_account_id)` (`accounts_funcs.sql`): назва, валюта (`id`,
    `code`), баланс і `can_delete` (на рахунку немає жодного запису, крім корекцій — `views.sql`). Порожня
    відповідь → «не знайдено».
  - назва й валюта — `update` в `accounts` за `id` з `select("id")` (порожньо → «не знайдено»); `currency_id`
    передаємо лише коли валюту можна змінювати (`ACC-10`).
  - баланс — RPC `adjust_account_balance(p_account_id, p_target_balance, p_local_offset, p_balance_date)`.
    Сервер сам рахує різницю з балансом **на кінець дня** `p_balance_date` (за місцевим часом) і не створює
    корекцію, якщо вона 0.
  - видалення — як web: спершу `delete` корекцій (`transactions`, `account_id` + `type = internal`), потім
    `delete` рахунку. Два запити не атомарні: якщо другий упаде, корекції вже зникнуть, а рахунок лишиться з
    іншим балансом. Web поводиться так само; окрему SQL-функцію не додаємо, але записуємо ризик у
    `ios/TECH_DEBT.md`.
- **Де живе код.** Усе в `Features/Wallet`: `WalletRepository` отримує `accountDetails(id:)`,
  `updateAccount(id:_:)`, `adjustBalance(_:)`, `deleteAccount(id:)` — як на web, де це `WalletRepository`.
- **Відкриття (`ACC-02`)** — картка стає `NavigationLink(value: AccountRoute(id:))`; «Налаштування рахунку» —
  екран у стеку навігації розділу (як редагування операції), а не sheet: у нього власні «Оновити» й «Видалити».
  `SectionView` отримує `navigationDestination(for: AccountRoute.self)`.
- **Свіжі дані при відкритті.** Екран завантажує рахунок за `id` із сервера (`GEN-23` — індикатор), а не бере
  картку зі списку: так `can_delete` і баланс актуальні. Рахунок, якого вже немає, — стан «не знайдено» з
  поверненням у Гаманець (як `TX-42`).
- **Форма (`ACC-09`, `ACC-10`)** — поля за зразком `AccountFormFields` / `TransactionFormFields`:
  - **Назва** — 3–30 символів, як `AccountFormViewModel.nameLength`;
  - **Валюта** — повний довідник з пошуком (`CurrencyPicker`, `GEN-11`). Якщо `can_delete == false` — поле
    недоступне, а над формою підказка «Щоб змінити валюту або видалити рахунок, видаліть усі пов'язані
    операції» (текст web `wallet.accountSettings.currencyInfo`);
  - **Баланс** — обов'язковий, ≤ 2 знаків, **може бути від'ємним** (кредитна картка; web теж не обмежує знак).
    Цифрова клавіатура без мінуса не підходить, тож поле — `.numbersAndPunctuation`, а розбір — новий
    `SignedAmountInput` поруч із `PositiveAmountInput` (той самий `DecimalInputParser` плюс необов'язковий
    мінус);
  - **«Баланс станом на»** — необов'язкова дата й час, не пізніше за зараз (`GEN-13`); за замовчуванням — зараз.
    На iOS це перемикач «Станом на іншу дату» + `DatePicker` з `in: ...now`; вимкнено — надсилаємо «зараз».
    `p_local_offset` — `LocalOffset.current(at:)` для вибраного моменту.
- **Збереження («Оновити»)** — як web: спершу назва/валюта, потім корекція, **лише якщо** введений баланс
  відрізняється від завантаженого (`ACC-09`: не змінено → корекції немає). Після успіху — назад у Гаманець
  (`ACC-12`). Помилка — «Не вдалося оновити рахунок» з поясненням сервера, дані форми лишаються (`GEN-19`). Якщо
  назва вже збереглася, а корекція впала, екран перечитує рахунок, щоб не показувати застарілу назву як
  незбережену.
- **Видалення (`ACC-11`, `GEN-22`, `Q-01`)** — лише коли `can_delete`; інакше кнопка недоступна (під нею та сама
  підказка). Підтвердження `confirmationDialog` із назвою рахунку. Після успіху — назад у Гаманець. Помилка — «Не
  вдалося видалити рахунок».
- **Оновлення інших екранів (`GEN-26`).** Нові `AppViewModel.accountUpdated()` / `accountDeleted()` перечитують
  довідкові дані (назва й валюта в пікерах форм і фільтрах) і збільшують `dataVersion`. Наслідки, які вже
  забезпечує `applyReferenceData()`:
  - основна валюта перераховується, якщо зникла її остання валюта (`NAV-11`, `PrimaryCurrencyResolver`);
  - видалення **останнього** рахунку переводить у Перше знайомство (`NAV-07`) — як і на web після перезапуску.
  Запам'ятований вибір для нових операцій із видаленим рахунком уже пропускається (`TX-16`).
- **Відома особливість web, яку відтворюємо:** зміна валюти рахунку, на якому є лише корекції, не перераховує їх —
  баланс лишається тим самим числом у новій валюті. Записуємо в `ios/TECH_DEBT.md` як питання до власника продукту.
- **Демо (`AUTH-10`).** `DemoWalletRepository.accountDetails(id:)` — з `DemoData.walletAccounts`; `can_delete` —
  `false` для рахунків, що мають демо-операції чи переказ (Main Card, Cash), `true` для Savings. `updateAccount`,
  `adjustBalance`, `deleteAccount` — no-op; після «збереження» чи «видалення» рахунок лишається як був.

## Кроки

### 1. Дані
- [ ] `AccountDetails` (id, назва, валюта `id`/`code`, баланс `Decimal`, `canDelete`) і `AccountDetailsDto`.
- [ ] `AccountUpdate` (назва, `currencyID?`) + DTO; `BalanceAdjustment` (рахунок, ціль, дата, offset) + DTO з
      `p_`-ключами.
- [ ] `WalletRepository`: `accountDetails(id:) -> AccountDetails?`, `updateAccount(id:_:) -> Bool` (`false` — не
      знайдено), `adjustBalance(_:)`, `deleteAccount(id:)`; `WalletMapper` для нових DTO.
- [ ] `SupabaseWalletRepository` — як web; `DemoWalletRepository` — деталі з `DemoData`, запис no-op.
- [ ] `FakeWalletRepository` у тестах: деталі, «не знайдено», запис викликів, помилки.
- [ ] Тести: мапер деталей (`NUMERIC` → `Decimal`, `can_delete`), DTO-ключі, демо-деталі й no-op.

### 2. Форма налаштувань (`ACC-09`, `ACC-10`)
- [ ] `SignedAmountInput` (обов'язкова, ≤ 2 знаків, дозволений мінус) + тести.
- [ ] `AccountSettingsViewModel`: `loading` / `loaded` / `notFound` / `failed`; поля, заповнені з деталей;
      валідація; `isCurrencyEditable`; `submit()` — оновлення, корекція лише при зміні балансу, `onSaved`;
      `delete()` з `isDeleting`, `deletionFailure`.
- [ ] Тести ViewModel: заповнення, помилки полів, від'ємний баланс, валюта недоступна при `!canDelete` і не
      потрапляє в запит, без корекції при незміненому балансі, корекція з датою й offset, «не знайдено» при
      відкритті й збереженні, помилка зберігає дані, видалення (виклик, повідомлення, помилка).

### 3. Екран і навігація (`ACC-02`, `ACC-11`, `ACC-12`)
- [ ] `AccountRoute(id:)`; картка в `WalletView` — `NavigationLink` з шевроном-підказкою.
- [ ] `AccountSettingsView`: підказка про валюту, поля, «Оновити» (`SubmitButton`), «Видалити» (руйнівна,
      `confirmationDialog`), стани завантаження / «не знайдено» / помилки. `SectionView.navigationDestination`.
- [ ] `AppViewModel.accountUpdated()` / `accountDeleted()` — перечитати довідкові дані й `dataChanged()`; тести.
- [ ] Прибрати коментар «stage 6» з `WalletView`.

### 4. Локалізація (en / uk / cs)
- [ ] Тексти з web (`wallet.translations.ts`: `accountSettings.header`, `currencyInfo`, `updateFailed`,
      `deleteFailed`; `newAccountForm.balanceLabel`, `balancePlaceholder`, `balanceError`, `balanceDateLabel`,
      `shared.update`) + нові: «Станом на іншу дату», підтвердження видалення, «не знайдено», дата в майбутньому.

### 5. Перевірка й документація
- [ ] Збірка й тести: `xcodebuild … -scheme Finwaze -destination 'platform=iOS Simulator,name=iPhone 18 Pro' test`.
- [ ] Критерії приймання ACC у симуляторі на локальному Supabase:
  - баланс 1 000 € на рахунку без операцій → 1 000 € у Гаманці, у списку операцій нічого нового;
  - баланс не змінено, змінено лише назву → корекції немає, нова назва в Гаманці й у пікерах форм;
  - баланс «станом на» минулу дату враховує лише операції до кінця того дня;
  - рахунок із витратою: валюта недоступна, «Видалити» недоступне, підказка видно;
  - рахунок без операцій, але з корекцією: змінити валюту й видалити можна; після видалення його немає ніде;
  - видалення останнього рахунку веде в Перше знайомство;
  - рахунок, видалений на web, відкривається як «не знайдено»;
  - демо: відкриття, збереження й видалення нічого не змінюють.
- [ ] Dark Mode, Dynamic Type, VoiceOver на екрані налаштувань.
- [ ] `ios/TECH_DEBT.md`: прибрати «account settings» з «Wallet is partial»; додати неатомарне видалення й
      валюту корекцій.
- [ ] Статус плану — «виконано».

## Ключові файли

- Нові: `Features/Wallet/Models/{AccountDetails,AccountDetailsDto,AccountUpdate,BalanceAdjustment,AccountRoute}.swift`,
  `Features/Wallet/ViewModels/AccountSettingsViewModel.swift`, `Features/Wallet/Views/AccountSettingsView.swift`,
  `Core/Formatting/SignedAmountInput.swift`, тести в `ios/FinwazeTests/Wallet/`.
- Змінюються: `Features/Wallet/Repositories/{WalletRepository,SupabaseWalletRepository}.swift`,
  `Features/Wallet/Mappers/WalletMapper.swift`, `Core/Demo/DemoWalletRepository.swift`,
  `Features/Wallet/Views/WalletView.swift`, `Features/Main/Views/SectionView.swift`, `App/AppViewModel.swift`,
  `Localizable.xcstrings`, `ios/TECH_DEBT.md`.
- Перевикористовуємо: `AccountFormViewModel.nameLength`, `CurrencyPicker`, `FormField`, `SubmitButton`,
  `FailureAlert`, `LocalOffset`, `DecimalInputParser`, `PositiveAmountInput` (як зразок), патерн
  `EditTransactionViewModel` / `TransferDetailsViewModel` (стани, «не знайдено», видалення з підтвердженням).
