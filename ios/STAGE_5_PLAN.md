# iOS — План етапу 5 «Перекази»

> **Статус:** не розпочато.

## Контекст

Етап 5 з `docs/functional-design.md` (розділ 6): **TRF-01…08 · ACC-01**. Залежить від етапу 3 (етап 4 уже
готовий). Зараз у Гаманці є лише «Додати рахунок», а рядок переказу в списку операцій не відкривається
(`TransactionRow`, `TransactionRoute` — «stage 5»). Результат для користувача: переміщення грошей між рахунками,
зокрема з обміном валют, перегляд і видалення переказу.

## Рішення

- **Схеми Supabase не змінюються.** Використовуємо те саме, що web:
  - створення — RPC `make_transfer(p_from_account_id, p_to_account_id, p_from_amount, p_to_amount,
    p_local_offset, p_transacted_at)` (`supabase/schemas/transfers_funcs.sql`); `p_to_amount` передаємо лише для
    різних валют, інакше `NULL` (сервер підставить відправлену суму). `p_comment` не передаємо (`Q-05`).
  - деталі — RPC `get_transfer_transactions(p_transaction_id)` (`transactions_funcs.sql:162`): повертає обидва
    записи переказу з тими самими колонками, що й `get_filtered_transactions`, тож перевикористовуємо
    `TransactionDto` + `TransactionMapper.toTransaction`. Порожня відповідь → «не знайдено».
  - видалення — `delete` з `transactions` за `transfer_id` (обидва записи разом), як
    `deleteTransferTransactions` на web.
- **Дії Гаманця (`ACC-01`)** — дві кнопки в тулбарі: нова ⇄ «Переказати гроші» поруч із наявним «+» «Додати
  рахунок». `SectionToolbar` отримує другу (необов'язкову) дію розділу: `AppSection.transferTitle` (лише для
  `.wallet`) + колбек `onTransfer`, за зразком `addTitle`/`onAdd`.
- **Форма переказу — sheet** (як «Нова операція» й «Новий рахунок»), `NavigationStack` з «Скасувати» (`NAV-05`)
  і `SubmitButton` «Перемістити гроші» (`GEN-20`). Поля й валідація (`GEN-21`):
  - «З рахунку» — обов'язково; зміна скидає «На рахунок» (`TRF-02`);
  - «Сума до відправлення» — обов'язково, > 0, ≤ 2 знаків (`DecimalInputParser`), у валюті рахунку-джерела;
  - «На рахунок» — список порожній/вимкнений, доки не вибрано джерело, і без джерела (`TRF-02`);
  - «Отримана сума» — лише коли валюти різні: обов'язкова, > 0; коли з'являється — порожня; під нею підказка
    курсу `1 EUR = 43,0000 UAH` (отримана ÷ відправлена, `TRF-03`, `GEN-10`);
  - «Дата й час» — `DatePicker` з `in: ...now`, за замовчуванням «зараз» (`GEN-13`); `p_local_offset` —
    `LocalOffset.current(at: date)`.
  - Лише звичайні рахунки — `ReferenceDataStore.accounts` уже без рахунків цілей (`TRF-04`); у пікері — назва й
    валюта.
  - Якщо рахунок лише один — під «На рахунок» пояснення «Щоб переказати гроші, потрібен ще один рахунок».
- **Курс (`GEN-10`).** Форматування курсу виносимо з `TransactionFormViewModel.exchangeRateHint` у спільне
  розширення в `Core/Formatting` (`Decimal.formattedExchangeRate` / `exchangeRateHint(from:to:)`), щоб форма
  витрати, форма переказу й деталі показували курс однаково. У деталях — 4 знаки, як web (`number: '1.4-4'`), і
  лише якщо курс ≠ 1 (`TRF-07`).
- **Після успіху (`TRF-05`)** — sheet закривається, `AppViewModel.transferMade()` збільшує `dataVersion`
  (`GEN-26`): Гаманець і список перечитаються. Помилка — `failureAlert` «Не вдалося виконати переказ» з поясненням
  сервера, дані форми лишаються (`GEN-19`).
- **Рядок переказу (`TRF-06`)** — підзаголовок «з <рахунку>» для від'ємного запису й «на <рахунок>» для додатного
  (локалізований формат), а не лише назва рахунку. Рядок стає `NavigationLink(value: TransferRoute(id:))`.
- **Деталі переказу (`TRF-07`, `TRF-08`)** — окремий екран у стеку навігації розділу (як редагування операції):
  `SectionView` отримує `navigationDestination(for: TransferRoute.self)`. Завантажується свіжо з сервера за `id`
  (`GEN-23` — індикатор). Показує: дату й час у збереженому `local_offset` (`GEN-12`); блок «Надіслано» (сума з
  валютою, «з <рахунку>»); стрілку; блок «Отримано» (сума, «на <рахунок>», курс якщо ≠ 1). Єдина дія —
  «Видалити» (руйнівна, `confirmationDialog`, `GEN-22`, `Q-01`); після успіху — зняти екран зі стеку й
  `transferDeleted()`. Помилка — «Не вдалося видалити переказ». Переказ, якого вже немає, — стан «не знайдено» з
  поверненням до списку (як `TX-42`); видалення вже видаленого — успіх.
- **Демо (`AUTH-10`).** Один демо-переказ на місяць: 100 USD з «Main Card» → 4 150 UAH на «Cash» (два записи
  `type: .transfer` з одним `transferID`, службова категорія як мітка), `id` у тій самій схемі `YYYYMM·100 + n`,
  щоб `transaction(id:)`/деталі знаходили його за `id`. `DemoTransfersRepository.make` і `delete` — no-op.

## Кроки

### 1. Дані
- [ ] `NewTransfer` (from/to account id, fromAmount, toAmount?, transactedAt, localOffset) і `NewTransferDto`
      з `p_`-ключами.
- [ ] `TransfersRepository` (у `Features/Transfers/Repositories`): `make(_:)`, `transfer(transactionID:) ->
      Transfer?` (`nil` — не знайдено), `delete(transferID:)`.
- [ ] Модель `Transfer` (id переказу, дата, offset, `sent: Transaction`, `received: Transaction`, `exchangeRate`)
      і `TransferMapper` з пари рядків (від'ємний → sent, додатний → received; неповна пара → `nil`).
- [ ] `SupabaseTransfersRepository`; `DemoTransfersRepository`; додати в обидва набори
      `Core/Repositories/Repositories.swift`.
- [ ] `DemoData+Transactions`: щомісячний демо-переказ (обидва записи) — видно в списку, фільтрах і деталях.
- [ ] Тести: мапер пари (порядок, курс у `Decimal`, неповна пара), DTO-ключі, демо-пошук переказу.

### 2. Форма переказу (`TRF-01…05`)
- [ ] `TransferFormViewModel`: стан полів, `toAccounts`, скидання «На рахунок», `showsReceivedAmount`, очищення
      отриманої суми при появі, валідація, `exchangeRateHint`, `submit()` з `isSubmitting` і `failure`.
- [ ] Спільне форматування курсу в `Core/Formatting`; `TransactionFormViewModel` переходить на нього.
- [ ] `TransferView` (sheet): поля за зразком `TransactionFormFields`/`FormField`, стрілка між блоками «З» і «На».
- [ ] `AppViewModel.transferMade()` / `transferDeleted()` → `dataChanged()`.
- [ ] Тести ViewModel: скидання одержувача, список без джерела, поява/зникнення отриманої суми, помилки полів,
      курс `4300 / 100 = 43`, запит з `p_to_amount = nil` для однакових валют, дата не в майбутньому, помилка
      зберігає дані.

### 3. Гаманець (`ACC-01`)
- [ ] `AppSection.transferTitle` + `onTransfer` у `SectionToolbar`; кнопка ⇄ поруч із «+».
- [ ] `SectionContentView`/`WalletView`: стан `isTransferring` і `.sheet { TransferView }`.

### 4. Список і деталі (`TRF-06…08`)
- [ ] `TransferRoute(id:)`; `TransactionRow` для переказу — `NavigationLink`, підзаголовок «з/на <рахунок>».
- [ ] `TransferDetailsViewModel` (`loading` / `loaded` / `notFound` / `failed`, `delete()` з `isDeleting`,
      `deletionFailure`).
- [ ] `TransferDetailsView`: блоки «Надіслано»/«Отримано», курс, «Видалити» з `confirmationDialog`, стан «не
      знайдено». `SectionView.navigationDestination(for: TransferRoute.self)`.
- [ ] Прибрати коментарі «stage 5» з `TransactionRoute`/`TransactionRow`.
- [ ] Тести ViewModel: завантаження, «не знайдено», видалення (виклик з `transferID`, `dataVersion`), помилка.

### 5. Локалізація (en / uk / cs)
- [ ] Тексти з web (`wallet.translations.ts`: `transfer.header`, `subheader`, `payFrom`, `amountToSend`,
      `destinationAccount`, `receivedAmount`, `moveMoney`, `creationFailed`; `transactions.translations.ts`:
      `transferDetails.*`, `transferDeletionFailed`) + нові: «з/на <рахунок>», підтвердження видалення переказу,
      «не знайдено», підказка про другий рахунок, мітка кнопки ⇄.

### 6. Перевірка й документація
- [ ] Збірка й тести: `xcodebuild … -scheme Finwaze -destination 'platform=iOS Simulator,name=iPhone 18 Pro' test`.
- [ ] Критерії приймання TRF у симуляторі на локальному Supabase (`supabase start`, користувач із ≥ 2 рахунками):
  - 100 USD «Картка USD» → «Готівка USD»: баланси −100/+100, доходи й витрати місяця не змінились (перевірити на web
    Дашборді), поля «Отримана сума» немає;
  - 100 EUR → 4 300 UAH: поле обов'язкове, підказка й деталі показують курс 43,0000;
  - у списку — два рядки «Переказ» «з …» / «на …»; натискання на будь-який → деталі;
  - видалення з підтвердженням прибирає обидва рядки й повертає баланси; переказ, видалений на web, → «не знайдено»;
  - дата в майбутньому недоступна; зміна «З рахунку» скидає «На рахунок»;
  - демо: переказ видно в списку й деталях; створення й видалення нічого не змінюють.
- [ ] Dark Mode, Dynamic Type, VoiceOver на формі переказу й деталях.
- [ ] `ios/TECH_DEBT.md`: прибрати «Transfer money» з «Wallet is partial» і деталі переказу з «Transactions are
      partial».
- [ ] Статус плану — «виконано».

## Ключові файли

- Нові: `ios/Finwaze/Features/Transfers/{Models,Repositories,Mappers,ViewModels,Views}/…`,
  `ios/Finwaze/Core/Demo/DemoTransfersRepository.swift`, тести в `ios/FinwazeTests/Transfers/`.
- Змінюються: `Core/Repositories/Repositories.swift`, `App/AppViewModel.swift`,
  `Features/Main/{Models/AppSection.swift,Views/SectionToolbar.swift,Views/SectionView.swift}`,
  `Features/Wallet/Views/WalletView.swift`, `Features/Transactions/Views/TransactionRow.swift`,
  `Features/Transactions/Models/TransactionRoute.swift`, `Features/Transactions/ViewModels/TransactionFormViewModel.swift`,
  `Core/Demo/DemoData+Transactions.swift`, `Localizable.xcstrings`, `ios/TECH_DEBT.md`.
- Перевикористовуємо: `TransactionDto`/`TransactionMapper`, `LocalOffset`, `DecimalInputParser`, `FormField`,
  `SubmitButton`, `FailureAlert`, `MoneyFormatting`, `DateFormatting.formattedTransactionDate(offset:)`,
  патерн `EditTransactionViewModel` (стани, «не знайдено», видалення).
