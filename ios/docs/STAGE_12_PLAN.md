# iOS — План етапу 12 «Віджети Гаманця»

> **Статус:** реалізовано; лишилась ручна перевірка частини критеріїв (див. крок 6).

## Контекст

Етап 12 з `docs/functional-design.md` (розділ 6): **ACC-03…06**. Залежить від етапу 3 (операції). Зараз Гаманець
(`WalletView`) показує лише картки рахунків, «Перевести кошти» й «Додати рахунок» (етапи 2, 5, 6); у
`ios/docs/TECH_DEBT.md` це записано як «Wallet is partial». Уже є все, на що спираються віджети: `TransactionRow` з
датою й переходами до редагування / деталей переказу (етап 8), `CardState` / `ContentCard` / `CardStateView` /
`CardEmptyState`, кільце з легендою й правилом «6 + Інші» (`BudgetCard` + `BudgetSummary`, `DASH-05`), картка з
графіком `CashFlowCard`, вибір місяця «‹ місяць ›» (`BudgetFilterCard`), основна валюта в `DevicePreferences` і
`MainNavigation.open(_:)`. Результат для користувача: під рахунками — щоденний рух коштів за місяць, останні операції
й статистика за групами, кожен віджет зі своїми фільтрами.

## Рішення

- **Схеми Supabase не змінюються.** Беремо ті самі RPC, що web (`wallet-repository.ts`):
  - `get_daily_transactions_cash_flow_for_month(p_currency_code, p_month)` — рядок на **кожен** день місяця
    (`day` DATE, `total_income`, `total_expense`), порожні дні — нулі, тож доповнювати не треба. Рахує за **валютою
    операції** (`transaction_amount`), без переказів і корекцій (`ACC-03`, `GEN-02`), дні — за місцевим часом операції
    (`GEN-12`). Витрати приходять від'ємними — мапер бере модуль, як web;
  - `get_filtered_transactions(p_transaction_currency_codes: [код], p_page_size: 3)` — 3 найновіші операції у валюті
    операції (`ACC-04`), без корекцій (`GEN-04`), новими першими. Рядок той самий, що в списку операцій, тож беремо
    наявні `TransactionDto` / `TransactionMapper`. Перекази в цій валюті теж потрапляють (кожна частина окремим
    рядком) — як на web і в списку операцій;
  - `get_monthly_transaction_amounts_by_group(p_month, p_currency_code)` — `group_id`, `group_name`, `total_income`,
    `total_expense` за місяць у валюті операції, лише доходи й витрати (службових груп там немає, `GEN-05`). Витрати
    від'ємні — модуль. Група може мати і доходи, і витрати — режим «Витрати» / «Доходи» бере лише ненульові.
  - `p_month` — `"YYYY-MM-01"` вибраного місяця в календарі пристрою (як Бюджет).
- **Де живе код.** `Features/Wallet`:
  - `WalletRepository` доповнюється: `dailyCashFlow(month:currencyCode:) -> [DailyCashFlow]`,
    `recentTransactions(currencyCode:limit:) -> [Transaction]`, `amountsByGroup(month:currencyCode:) -> [GroupAmounts]`;
    реалізації — у `SupabaseWalletRepository` і `DemoWalletRepository`;
  - моделі: `DailyCashFlow` (день, доходи, витрати) + `DailyCashFlowDto`, `GroupAmounts` (id і назва групи, доходи,
    витрати) + `GroupAmountsDto`, `WalletWidgetFilter` (див. нижче); `WalletMapper` — `toDailyCashFlow` (день із
    `"YYYY-MM-DD"` як календарний день у поясі пристрою, як `targetDate` цілей; модуль витрат), `toGroupAmounts`.
- **Кільце й «6 + Інші» — спільні з Дашбордом.** `BudgetSummary` / `BudgetSlice` перейменовуємо на `SliceSummary` /
  `ChartSlice` і переносимо в `Shared/Models`, а кільце з сумою в центрі й легенду з `BudgetCard` — у
  `Shared/Views/DonutChart.swift` (підпис центру й назва «Інших» — параметри). `BudgetCard` лишається тонкою обгорткою.
  Правило те саме, що на web і в `DASH-05`: до 7 елементів — усі; більше — 6 найбільших + «Інші категорії» з сумою
  решти (`ACC-05`). Кольори — та сама палітра, «Інші» — сірий (RPC не повертає кольору групи, web теж бере палітру).
  Вхід кільця — `NamedAmount` (назва + сума); для бюджету — `SliceSummary(budgets:)`.
- **Фільтри віджетів (`ACC-06`).** Кожен віджет має власний `WalletWidgetFilter` (`@Observable`): місяць
  (`YearMonth`, за замовчуванням поточний, `GEN-14`) і `currencyCode: String?`. Як у `BudgetFilter`: `nil`, доки
  користувач не вибрав валюту сам, — тоді віджет бере основну валюту (`DASH-01`); вибрана вручну основною вже не
  перезаписується; валюта, якої більше немає серед валют рахунків, падає на основну, далі на першу (`GEN-11`). Фільтри
  тримає `WalletView` через `@State`, а вкладка живе весь сеанс, тож вибір зберігається, поки користувач у застосунку;
  вихід з акаунта починає новий сеанс. Фільтри віджетів один від одного не залежать.
- **ViewModel-и.** Замість одного великого — по одному на віджет, кожен зі своїм фільтром, `CardState` і перезавантаженням
  лише себе (незалежні фільтри й помилки, `GEN-25`). Завантаження однакове для всіх трьох, тож воно в одному
  узагальненому `WalletWidgetViewModel<Value>` (фільтр, валюти, стан, `load` / `refresh`), а віджети його складають:
  - `DailyCashFlowViewModel` — `widget: WalletWidgetViewModel<[DailyCashFlow]>`, `includesIncome` (за замовчуванням
    `true`; перемикач лише ховає доходи на графіку, без запиту, як web);
  - «Останні операції» — `WalletWidgetViewModel<[Transaction]>.recentTransactions(…)`, лише валюта (місяця немає);
  - `WalletStatisticsViewModel` — `widget: WalletWidgetViewModel<[GroupAmounts]>`, режим `.expense` / `.income` (за
    замовчуванням витрати, без запиту), `summary(of:)` для кільця й суми «Загальні витрати / доходи»;
  - спільна логіка «вибрана валюта → основна → перша» — у `WalletWidgetFilter` (одне місце, одні тести);
  - завантаження — як `DashboardViewModel.load`: `.task(id: LoadKey(month, currency, dataVersion))` на кожному віджеті;
    перезавантаження після зміни даних лишає старі цифри до нових (`GEN-26`), зміна місяця чи валюти — показує
    скелетон (цифри в старій валюті гірші за скелетон); відповідь для вже не вибраного фільтра відкидається.
    Що показано, запам'ятовується лише після відповіді: завантаження, перерване переходом на іншу вкладку, повториться
    при поверненні, а не залишить вічний скелетон.
  - `WalletViewModel` (картки рахунків) не змінюється.
- **«Щоденний рух коштів» (`ACC-03`)** — `DailyCashFlowCard`:
  - угорі: «‹ вересень 2026 ›» (`MonthStepper`, винесений з `BudgetFilterCard`) і меню валюти — `CurrencyFilterMenu`
    (чип «USD ⌄», як у фільтрах Бюджету й огляді цілей; тепер його беруть і вони). `CurrencyMenu` дашборда — велика
    кнопка вгорі екрана — лишається як є. Нижче перемикач «Показувати доходи» (`Toggle` з підписом);
  - Swift Charts: дві лінії, доходи й витрати по днях (`LineMark`, згладжені `.monotone`, без точок; витрати —
    додатними значеннями), як на web. `.catmullRom` (аналог `tension: 0.4` web) біля різких піків опускав лінію нижче
    нуля, `.monotone` так не робить. Доходи — акцентним кольором, витрати — помаранчевим пунктиром (не лише кольором). 31 день × 2 стовпчики на ширині iPhone
    були б надто вузькими, а лінії краще показують динаміку місяця. Підписи осі X — число дня кожні ~5 днів,
    `chartXSelection` показує вертикальну позначку й суми вибраного дня (аналог тултіпа web). Пояснення з тултіпа web
    («за сумою операції…») — підзаголовком картки, як на `CashFlowCard`;
  - вимкнені доходи — лише лінія витрат і легенда без доходів;
  - місяць без доходів і витрат — графік із нулями й короткий напис «Немає доходів і витрат за цей місяць».
- **«Останні операції» (`ACC-04`)** — `WalletRecentTransactionsCard` на основі `RecentTransactionsCard` дашборда:
  спільне тіло (3 рядки `TransactionRow(showsDate: true)`, розділювачі, скелетон) виносимо в `RecentTransactionsList`,
  картка Гаманця додає меню валюти. Натискання рядка — редагування чи деталі переказу (`TX-06`; `SectionView` уже має ці
  `navigationDestination`). «Усі операції» → вкладка Операції (`MainNavigation.open(.transactions)`) без фільтра валюти,
  як web. Порожньо — «Поки немає операцій у %@» + «Додати операцію» (відкриває `NewTransactionView`).
- **«Статистика» (`ACC-05`)** — `WalletStatisticsCard`: місяць і валюта (ті самі елементи), сегментований `Picker`
  «Витрати / Доходи», `DonutChart` з «Загальні витрати» / «Загальні доходи» в центрі й легендою: колір, назва групи,
  частка у % і сума з валютою (`GEN-06`; web показує суму без валюти). Порожньо в режимі — «Немає витрат / доходів за
  цей місяць».
- **Макет екрана.** Зараз стани `WalletView` (завантаження / порожньо / помилка) — на весь екран. Переробляємо на один
  `ScrollView`: сітка карток рахунків → «Щоденний рух коштів» → «Останні операції» → «Статистика». Помилка рахунків
  показується в їхньому блоці (картка «Рахунки» з `CardErrorView`, винесеним із `CardStateView`) з «Спробувати ще
  раз» і не ховає віджети (`GEN-25`). Порожній Гаманець (без рахунків —
  у головному застосунку не буває, `NAV-07`) лишається повноекранним станом без віджетів. У горизонтальній орієнтації —
  адаптивна сітка віджетів у дві колонки, як на дашборді. Pull-to-refresh перечитує рахунки й усі три віджети.
- **Оновлення даних (`GEN-26`).** Віджети перечитуються на `app.dataVersion`: нова, змінена чи видалена операція,
  переказ, корекція балансу, внесок у ціль. Окремих дій в `AppViewModel` не потрібно.
- **Демо (`AUTH-10`).** `DemoWalletRepository` рахує з тих самих демо-операцій, що й список операцій
  (`DemoData.transactions(inMonthOf:)`), щоб цифри збігалися (web показує фіксовані числа):
  - щоденний рух — доходи й витрати за валютою операції по кожному дню місяця, без переказів; порожні дні — нулі;
  - останні операції — 3 найновіші у валюті операції з цього й минулого місяця (як `DemoDashboardRepository`);
  - статистика — суми доходів і витрат за групами (`group.id`) за місяць у валюті операції.
  Запису у віджетах немає, тож no-op методів не потрібно.

## Кроки

### 1. Дані
- [x] Моделі `DailyCashFlow`, `GroupAmounts` + DTO; `WalletMapper.toDailyCashFlow` / `toGroupAmounts`.
- [x] `WalletRepository`: `dailyCashFlow`, `recentTransactions`, `amountsByGroup`; `SupabaseWalletRepository` (параметри
      з `p_` і точними назвами, `p_month` — `"YYYY-MM-01"`).
- [x] `DemoWalletRepository`: три методи з `DemoData.transactions(inMonthOf:)`.
- [x] Тести: мапер (модуль витрат, день `"2026-09-30"` лишається 30-м на пристрої в UTC−5 і UTC+2, `Decimal` без
      втрати точності); кодування параметрів; демо — суми по днях і групах збігаються з демо-операціями, перекази не
      входять, валюта без операцій → нулі / порожньо.

### 2. Спільні частини
- [x] `BudgetSummary` / `BudgetSlice` → `Shared/Models/SliceSummary.swift` (`SliceSummary`, `ChartSlice`); кільце й
      легенда з `BudgetCard` → `Shared/Views/DonutChart.swift`; `BudgetCard` на них. Наявні тести `BudgetSummary`
      переносяться під нову назву.
- [x] `CurrencyFilterMenu` у `Shared/Views` (чип валюти з меню); на ньому й фільтри Бюджету та огляд цілей.
- [x] `RecentTransactionsList` з `RecentTransactionsCard` → спільне тіло для обох карток.
- [x] Перемикач місяця «‹ місяць ›» з `BudgetFilterCard` → `Shared/Views/MonthStepper.swift`, `BudgetFilterCard` на ньому.

### 3. ViewModel-и
- [x] `WalletWidgetFilter`: місяць, вибрана валюта, `resolvedCurrencyCode(codes:primary:)`.
- [x] `WalletWidgetViewModel<Value>` (стан, завантаження за ключем, відкидання застарілих відповідей, повтор);
      `DailyCashFlowViewModel`, `WalletStatisticsViewModel`, `.recentTransactions(…)` на ньому.
- [x] Тести: без вибору віджет бере основну валюту й іде за її зміною; після вибору вручну зміна основної не впливає;
      зникла валюта → основна; зміна фільтра одного віджета не перезавантажує інших; помилка одного віджета не
      зачіпає інших; перемикач доходів і режим статистики не роблять запиту; статистика: лише ненульові групи в режимі,
      8 груп → 6 + «Інші», частки в сумі 100 %; повернення без змін нічого не вантажить.

### 4. Екран
- [x] `WalletView` (тепер `init(app:…)`): один `ScrollView` з блоком рахунків (свої стани) і трьома віджетами; фільтри
      й ViewModel-и віджетів у `@State`; pull-to-refresh.
- [x] `DailyCashFlowCard` (Swift Charts, лінії, вибір дня), `WalletRecentTransactionsCard`, `WalletStatisticsCard`.
- [x] «Усі операції» → `MainNavigation.open(.transactions)`; «Додати операцію» в порожньому стані — `NewTransactionView`.
- [x] VoiceOver: кожна точка графіка — день, ряд і сума з валютою (як на `CashFlowCard`); сектори й рядки легенди —
      назва, частка, сума; перемикачі й меню з підписами.

### 5. Локалізація (en / uk / cs)
- [x] Тексти з web (`wallet.translations.ts`: `statistics.*`, `transactionsOverview.*`); назви віджетів — з документа:
      «Щоденний рух коштів» (web: «Daily Transaction Flow»), «Інші категорії».
- [x] Нові: «Поки немає транзакцій у %@», «Немає доходів і витрат за цей місяць», «Немає витрат / доходів за цей
      місяць», «Показувати доходи», «Рахунки», суми вибраного дня. «Усі транзакції», «Останні транзакції», «Інші
      категорії», «Доходи» / «Витрати» — ключі дашборда.

### 6. Перевірка й документація
- [x] Збірка й тести: `xcodebuild … -scheme Finwaze -destination 'platform=iOS Simulator,name=iPhone 18 Pro' test`.
- [x] RPC перевірено на локальному Supabase тими самими параметрами (усі дні місяця, валюта операції, `group_id`).
- [x] Екран у симуляторі в демо-режимі (uk, 28.09.2026): рахунки, щоденний рух (USD, вересень), останні 3 транзакції,
      статистика з частками й «Загальні витрати» — цифри збігаються з демо-операціями.
- [ ] Критерії приймання ACC-03…06 у симуляторі на локальному Supabase:
  - витрата 5 € з гривневого рахунку з'являється в EUR-віджетах (за валютою операції), а не в UAH;
  - переказ між рахунками не змінює щоденного руху й статистики, але видно в останніх операціях;
  - «Доходи вимк.» лишає лише витрати; повернення до віджета після іншої вкладки зберігає вимкнений стан;
  - статистика з понад 7 групами показує 6 + «Інші категорії» і загальну суму під кільцем;
  - зміна валюти чи місяця в одному віджеті не змінює інших; вибір зберігається після переходу на інші вкладки;
  - основна валюта з дашборда — початкова для кожного віджета, доки в ньому не вибрали іншу;
  - нова операція оновлює віджети при поверненні в Гаманець;
  - демо: цифри віджетів збігаються з демо-операціями.
- [ ] Dark Mode, Dynamic Type (найбільші розміри — фільтри віджетів переносяться), VoiceOver.
- [x] `ios/docs/TECH_DEBT.md`: прибрати «Wallet is partial».
- [x] Статус плану — «виконано».

## Ключові файли

- Нові: `Features/Wallet/Models/{DailyCashFlow,DailyCashFlowDto,GroupAmounts,GroupAmountsDto,WalletWidgetFilter}.swift`,
  `Features/Wallet/ViewModels/{DailyCashFlowViewModel,WalletStatisticsViewModel}.swift`,
  `Features/Wallet/Views/{DailyCashFlowCard,WalletRecentTransactionsCard,WalletStatisticsCard}.swift`,
  `Features/Wallet/ViewModels/WalletWidgetViewModel{,+RecentTransactions}.swift`,
  `Features/Wallet/Views/WalletWidgetFilterBar.swift`, `Shared/Models/SliceSummary.swift`,
  `Shared/Views/{DonutChart,CurrencyFilterMenu,MonthStepper}.swift`,
  `Features/Transactions/Views/RecentTransactionsList.swift`, тести в `ios/FinwazeTests/Wallet/`.
- Змінюються: `Features/Wallet/Repositories/{WalletRepository,SupabaseWalletRepository}.swift`,
  `Features/Wallet/Mappers/WalletMapper.swift`, `Features/Wallet/Views/WalletView.swift`,
  `Core/Demo/DemoWalletRepository.swift`, `Features/Dashboard/Views/{BudgetCard,RecentTransactionsCard}.swift`,
  `Features/Dashboard/Models/BudgetSummary.swift` (переноситься), `Features/Dashboard/Models/CategoryBudget.swift`,
  `Features/Budget/Views/BudgetFilterCard.swift`, `Features/Goals/Views/SavingsOverviewCard.swift`,
  `Features/Main/Views/SectionView.swift`, `Shared/Views/ContentCard.swift` (`CardErrorView`),
  `ios/FinwazeTests/Wallet/{FakeWalletRepository,WalletMapperTests}.swift`, тести `SliceSummary` у Dashboard,
  `Localizable.xcstrings`, `ios/docs/TECH_DEBT.md`.
- Перевикористовуємо: `TransactionDto` / `TransactionMapper`, `TransactionRow`, `CardState` / `ContentCard` /
  `CardStateView` / `CardEmptyState`, `YearMonth`, `DevicePreferences.primaryCurrencyCode`,
  `ReferenceDataStore.accountCurrencyCodes`, `MainNavigation`, картка графіка за зразком `CashFlowCard`.
- Джерело поведінки на web: `src/app/features/wallet/**` (`pages/wallet`, `ui/transactions-overview-*`,
  `ui/statistics-widget`, `ui/wallet-recent-transactions-card`, `stores/wallet-*-store.ts`,
  `repositories/wallet-repository.ts`), переклади — `src/app/core/i18n/wallet.translations.ts`; SQL:
  `supabase/schemas/charts_funcs.sql`, `supabase/schemas/transactions_funcs.sql`.
