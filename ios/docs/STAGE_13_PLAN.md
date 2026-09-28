# iOS — План етапу 13 «Аналітика»

> **Статус:** план; реалізацію не розпочато.

## Контекст

Етап 13 з `docs/functional-design.md` (розділ 6): **ANL-01…06**. Залежить від етапу 9 (перегляд бюджету). Зараз
Аналітика — другорядний розділ (`NAV-02`), який відкривається з меню «Більше» будь-якого розділу, але
`SectionContentView` показує для неї заглушку «у розробці» (`ios/docs/TECH_DEBT.md` → «Section placeholders»). Уже є
все, на що спирається екран: підсумкові картки з бейджем зміни (`SummaryCard`, `TrendChange`, `TrendBadge`, `DASH-03`),
кільце з легендою й правилом «6 + Інші» (`DonutChart`, `SliceSummary`), лінійний графік з вибором дня
(`DailyCashFlowCard`), стовпчики по місяцях (`CashFlowCard`), `MonthStepper`, `CurrencyFilterMenu`, `FilterChip`,
основна валюта в `DevicePreferences`, бюджети по групах (`BudgetRepository.budgets`, `get_monthly_budgets_by_groups`)
і завантаження карток за ключем з відкиданням застарілих відповідей (`WalletWidgetViewModel`). Результат для
користувача: порівняння місяця з попереднім, структура доходів, витрат і бюджету за групами та бюджет проти витрат
за рік — з фільтрами місяця, валюти й рахунків.

## Рішення

- **Схеми Supabase не змінюються.** Беремо ті самі RPC, що web (`analytics-repository.ts`). Усі, крім бюджетних,
  рахують за **сумою списання** в рахунках вибраної валюти (`charged_amount`, `charged_currency_id`, `ANL-06`), дні й
  місяці — за місцевим часом операції (`GEN-12`), доходи й витрати — без переказів і корекцій (`GEN-02`):
  - `get_analytics_financial_summary(p_month, p_currency_code, p_account_ids)` — один рядок: доходи й витрати місяця та
    попереднього, баланс на кінець місяця й попереднього (усі записи до кінця місяця, з переказами й корекціями —
    `GEN-03`), кількість операцій доходу / витрат і кількість груп доходу / витрат. Витрати вже додатні;
  - `get_daily_financial_overview_for_month(p_month, p_currency_code, p_account_ids)` — рядок на **кожен** день
    місяця (`day`, `daily_income`, `daily_expense` додатні, `running_balance` — баланс на кінець дня з урахуванням
    усього до місяця). Викликаємо двічі паралельно — для вибраного й попереднього місяця, як web;
  - `get_analytics_amounts_by_groups(p_month, p_currency_code, p_account_ids)` — `group_id`, `group_name`,
    `income_amount`, `expense_amount` (обидві додатні), без службових груп (`GEN-05`);
  - бюджет за групами — наявний `BudgetRepository.budgets(BudgetQuery(month:currencyCode:groupID: nil))`
    (`get_monthly_budgets_by_groups`), беремо `planned > 0`. Рахунків він не знає — фільтр рахунків не впливає
    (`ANL-05`);
  - `get_yearly_budgets_vs_expenses(p_year, p_currency_code)` — 12 рядків (`month` — перше число, `budget_amount`,
    `expense_amount` додатні). Витрати — за **валютою рахунку**, план — за валютою бюджету. Рахунків не знає (`ANL-04`).
  - `p_month` — `YearMonth.firstDayParameter` (`"YYYY-MM-01"`, як Бюджет і Гаманець); `p_account_ids` — масив id
    вибраних рахунків, а без вибору ключ **не передаємо** (у SQL `DEFAULT NULL` = усі рахунки валюти, зокрема рахунки
    цілей — так баланс збігається з дашбордом). Web у цьому випадку шле `null`, результат той самий.
- **Розбіжність `Q-03` відтворюємо як є:** «Бюджети vs Витрати» рахує витрати за валютою рахунку, а екран Бюджет — за
  валютою покупки, тож цифри можуть відрізнятися. Пояснення — підзаголовком картки («Витрати — за сумою списання в
  рахунках <валюта>»), як на `CashFlowCard`.
- **Де живе код.** Нова фіча `Features/Analytics/{Models,Repositories,Mappers,ViewModels,Views}`:
  - `AnalyticsRepository` (протокол): `summary(_ query: AnalyticsQuery) -> AnalyticsSummary`,
    `dailyOverview(_ query:) -> [DailyOverviewPoint]`, `amountsByGroup(_ query:) -> [GroupAmounts]`,
    `yearlyBudgetsVsExpenses(year:currencyCode:) -> [MonthlyBudgetExpense]`; `SupabaseAnalyticsRepository`,
    `DemoAnalyticsRepository` (`Core/Demo`), обидва — у `Repositories.live` / `.demo`;
  - `AnalyticsQuery` (`month: YearMonth`, `currencyCode`, `accountIDs: Set<Int64>`) — він же ключ завантаження;
  - моделі й DTO: `AnalyticsSummary` + `AnalyticsSummaryDto`, `DailyOverviewPoint` (день, доходи, витрати, баланс) +
    `DailyOverviewPointDto`, `MonthlyBudgetExpense` + `MonthlyBudgetExpenseDto`; суми по групах — наявні
    `GroupAmounts` із Гаманця (новий `AnalyticsGroupAmountsDto`, бо інші назви колонок); `AnalyticsMapper`. Дні й
    місяці з `"YYYY-MM-DD"` — календарні дні в поясі пристрою, як `WalletMapper.toDailyCashFlow`.
- **Фільтри (`ANL-01`)** — `AnalyticsFilter` (`@Observable`): місяць (`YearMonth`, за замовчуванням поточний,
  `GEN-14`), `pickedCurrencyCode: String?` і `accountIDs: Set<Int64>`.
  - Валюта — як `WalletWidgetFilter`: `nil`, доки не вибрано вручну, тоді основна (`DASH-01`); зникла валюта → основна
    → перша (`GEN-11`). Спільну логіку «вибрана → основна → перша» виносимо з `WalletWidgetFilter` у
    `CurrencySelection` (`Shared/Models`), щоб вона була в одному місці з одними тестами.
  - Рахунки — звичайні рахунки вибраної валюти з `ReferenceDataStore.accounts` (як web — без рахунків цілей). Порожньо
    = усі. Зміна валюти очищає вибір рахунків (як web). Рахунок, якого вже немає (видалено чи змінено валюту), з
    вибору випадає; якщо не лишилось жодного — це знову «усі».
  - Аналітика — екран, що відкривається поверх розділу (`path.append`), тож `@State` у ньому губиться після «Назад».
    Web тримає фільтри весь сеанс (root-store). Тому `AnalyticsFilter` створює `MainTabView` (`@State`, живе весь
    сеанс; після виходу з акаунта створюється новий) і передає через `environment`, як `MainNavigation`. Рік картки
    «Бюджети vs Витрати» живе там само (`AnalyticsFilter.budgetYear`, за замовчуванням поточний).
- **Спільне завантаження карток.** Ядро `WalletWidgetViewModel` (стан, `load(dataVersion:)` за ключем, скелетон при
  зміні ключа й старі цифри при зміні даних, відкидання відповіді для вже не вибраного ключа, `refresh`) узагальнюємо до
  `CardLoader<Key: Equatable, Value>` у `Shared/ViewModels`; `WalletWidgetViewModel` лишається на ньому з тим самим
  API, його тести не змінюються. Аналітика складається з чотирьох завантажувачів, кожен зі своїм `CardState` (помилка
  однієї картки не ламає інших, `GEN-25`):
  - `summary: CardLoader<AnalyticsQuery, AnalyticsSummary>` — три підсумкові картки;
  - `overview: CardLoader<AnalyticsQuery, MonthlyOverview>` — обидва місяці разом (`async let`), бо лінії без
    попереднього місяця не мають сенсу;
  - `statistics: CardLoader<AnalyticsQuery, GroupStatistics>` — суми по групах і бюджет по групах паралельно;
  - `budgetsVsExpenses: CardLoader<YearKey, [MonthlyBudgetExpense]>` — ключ `(рік, валюта)`, тож фільтри місяця й
    рахунків її не перезавантажують (`ANL-04`).
  `AnalyticsViewModel` тримає їх, фільтр і локальні перемикачі без запиту: показник огляду (`.balance` за
  замовчуванням / `.income` / `.expense`) і режим статистики (`.expense` за замовчуванням / `.income` / `.budget`).
- **Підсумкові картки (`ANL-02`)** — `AnalyticsSummaryCard` на основі `SummaryCard` дашборда: `SummaryKind` і бейдж ті
  самі (`TrendChange`, ріст балансу й доходів — добре, витрат — погано). Додається:
  - речення «на <різниця з валютою> більше / менше, ніж минулого місяця» або «так само, як минулого місяця» (без суми,
    коли різниці немає) — `SummaryComparison` (модель: різниця за модулем і напрям) з тестами;
  - «<N> операцій · <M> груп» (плюралізація в String Catalog). Для балансу — суми по доходах і витратах, як web
    (група з доходами й витратами рахується двічі — так само, як на web).
  - Картка дашборда не змінюється; спільне тіло (сума + бейдж) виносимо, щоб не дублювати.
- **«Місячний огляд» (`ANL-03`)** — `MonthlyOverviewCard`:
  - угорі сегментований `Picker` «Баланс / Доходи / Витрати»;
  - Swift Charts: дві лінії по **числу дня** (1…31), щоб місяці різної довжини лягли одне на одне (web вирівнює за
    індексом — те саме); вибраний місяць — суцільна лінія акцентного кольору з заливкою градієнтом (`AreaMark`, як
    web), попередній — пунктир (не лише колір). `.monotone`, без точок, як `DailyCashFlowCard`. Лінія попереднього
    місяця закінчується на його останньому дні. Баланс може бути від'ємним — вісь Y не обрізається на нулі;
  - легенда з назвами місяців («вересень 2026» / «серпень 2026») замість web-овських «Вибраний / Попередній місяць»
    — зрозуміліше; `chartXSelection` показує позначку дня й обидва значення з валютою;
  - поточний місяць має дні в майбутньому: баланс там стоїть на місці, доходи й витрати — нулі, як web.
- **«Бюджети vs Витрати» (`ANL-04`)** — `BudgetsVsExpensesCard`: власний перемикач року «‹ 2026 ›» (як `MonthStepper`,
  крок — рік; `YearStepper` у `Shared/Views` або параметр кроку в `MonthStepper`), 12 пар стовпчиків (`BarMark`,
  `.position(by:)`): витрати — акцентним, бюджет — світлішим відтінком зі штриховкою або обведенням, щоб відрізнялись
  не лише кольором. Підписи осі X — вузькі назви місяців (`.narrow`: «с», «ж»…), у горизонтальній орієнтації —
  короткі. `chartXSelection` → суми бюджету й витрат місяця з валютою. Рік без жодного бюджету й витрат — нулі й
  напис «Немає бюджетів і витрат за цей рік».
- **«Статистика» (`ANL-05`)** — `AnalyticsStatisticsCard`: сегментований `Picker` «Витрати / Доходи / Бюджет»,
  `DonutChart` з підписом центру «Витрати за вересень 2026» (web: «… за 09/26») і сумою, легенда: колір, група, частка у
  % і сума з валютою (`GEN-06`). Лише групи з сумою > 0, найбільші першими. Правило «до 7 — усі, більше — 6 + Інші» —
  те саме, що в Гаманці й на дашборді (`SliceSummary`); web тут показує всі групи, але на екрані iPhone довга легенда
  й дрібні сектори гірші, а сума «Інших» видна. Порожньо в режимі — «Немає витрат / доходів / бюджету за цей місяць».
- **Екран** — `AnalyticsView` замість заглушки в `SectionContentView`:
  - один `ScrollView`: панель фільтрів → три підсумкові картки → «Місячний огляд» → «Бюджети vs Витрати» →
    «Статистика» (порядок web);
  - панель фільтрів — `AnalyticsFilterBar`: `MonthStepper`, `CurrencyFilterMenu` і чип рахунків `FilterChip` «Усі
    рахунки ⌄» / «Main Card» / «2 рахунки» з `Menu` (пункт «Усі рахунки» + `Toggle` на кожен рахунок валюти,
    `.menuActionDismissBehavior(.disabled)`, щоб вибрати кілька за раз). На вузькому екрані й великому Dynamic Type
    панель переноситься (`ViewThatFits` / `FlowLayout`), як фільтри віджетів Гаманця;
  - у портретній орієнтації картки — одна колонка; у горизонтальній — три підсумкові в ряд, а графіки в адаптивній сітці
    з двох колонок, як на дашборді;
  - завантаження — `.task(id:)` на ключ кожного завантажувача + `app.dataVersion` (`GEN-26`: нова операція, переказ,
    корекція, бюджет, внесок у ціль). Pull-to-refresh перечитує всі чотири. Скелетони — `CardStateView` з
    плейсхолдерами (`GEN-23`).
- **Демо (`AUTH-10`)** — `DemoAnalyticsRepository` рахує з `DemoData.transactions(inMonthOf:)`, як Гаманець і
  дашборд, щоб цифри збігались (web показує фіксовані числа):
  - доходи й витрати, кількість операцій і груп, суми по групах і щоденні суми — за сумою списання в рахунках валюти,
    лише рахунки з фільтра (порожньо = усі), без переказів;
  - баланс на кінець місяця M = поточний баланс рахунків валюти (з фільтра; без фільтра — разом із цілями, як
    `DemoDashboardRepository`) − сума всіх записів (з переказами) після M до сьогодні; для майбутнього місяця — поточний
    баланс. Щоденний баланс — так само на кінець кожного дня;
  - бюджет по групах — наявний `DemoBudgetRepository`; «Бюджети vs Витрати» — план `DemoBudgetRepository` (той самий
    план щомісяця до поточного) і витрати за валютою рахунку.
  Запису немає, тож no-op методів не потрібно.

## Кроки

### 1. Дані
- [ ] `AnalyticsQuery`; моделі `AnalyticsSummary`, `DailyOverviewPoint`, `MonthlyBudgetExpense` + DTO,
      `AnalyticsGroupAmountsDto`; `AnalyticsMapper`.
- [ ] `AnalyticsRepository` + `SupabaseAnalyticsRepository` (точні назви параметрів з `p_`; `p_account_ids` не
      передається без вибору); `Repositories.live` / `.demo`, `FakeAnalyticsRepository` для тестів.
- [ ] `DemoAnalyticsRepository` на `DemoData`.
- [ ] Тести: мапер (`Decimal` без втрати точності, день `"2026-09-30"` лишається 30-м в UTC−5 і UTC+2, місяці року по
      порядку); кодування параметрів (з рахунками й без — ключа немає); демо — підсумки збігаються з демо-операціями,
      перекази не входять у доходи й витрати, але входять у баланс; баланс на кінець минулого місяця = поточний − записи
      цього місяця; фільтр рахунку лишає лише його операції; валюта без рахунків → нулі.

### 2. Спільні частини
- [ ] `CardLoader<Key, Value>` у `Shared/ViewModels` з ядра `WalletWidgetViewModel`; Гаманець на ньому, його тести
      зелені без змін.
- [ ] `CurrencySelection` («вибрана → основна → перша») з `WalletWidgetFilter`; Гаманець на ньому.
- [ ] Тіло підсумкової картки (сума + `TrendBadge`) з `SummaryCard` — для дашборда й аналітики.
- [ ] Перемикач року: `YearStepper` або крок у `MonthStepper`.

### 3. ViewModel-и
- [ ] `AnalyticsFilter` (місяць, валюта, рахунки, рік картки) у `MainTabView` через `environment`.
- [ ] `AnalyticsViewModel`: чотири `CardLoader`, показник огляду, режим статистики, `SummaryComparison`,
      `summary(of:)` для кільця.
- [ ] Тести: без вибору — основна валюта й іде за її зміною, після вибору вручну — ні; зміна валюти очищає рахунки;
      рахунок, що зник, випадає з вибору; зміна місяця чи рахунків не перезавантажує «Бюджети vs Витрати», а зміна року —
      інших карток; помилка однієї картки не зачіпає інших; перемикачі показника й режиму не роблять запиту; режим
      «Бюджет» ігнорує рахунки (ключ без них); статистика — лише ненульові групи, 8 груп → 6 + «Інші», частки в сумі
      100 %; речення порівняння — більше / менше / так само, різниця за модулем; повернення на екран без змін нічого
      не вантажить.

### 4. Екран
- [ ] `AnalyticsView` у `SectionContentView` замість заглушки; `AnalyticsFilterBar` (місяць, валюта, рахунки).
- [ ] `AnalyticsSummaryCard` ×3, `MonthlyOverviewCard` (лінії, заливка, вибір дня), `BudgetsVsExpensesCard`
      (стовпчики, рік, вибір місяця), `AnalyticsStatisticsCard` (кільце, легенда).
- [ ] Макет для портретної й горизонтальної орієнтації; pull-to-refresh; скелетони.
- [ ] VoiceOver: кожен день графіка — «<день>: <місяць> — сума, <попередній місяць> — сума»; кожен місяць стовпчиків —
      бюджет і витрати з валютою; сектори й рядки легенди — назва, частка, сума; меню рахунків озвучує вибрані; бейдж
      — як на дашборді.

### 5. Локалізація (en / uk / cs)
- [ ] Тексти з web (`src/app/core/i18n/analytics.translations.ts`: `financialSummary.*`, `monthlyOverview.*`,
      `budgetsExpenses.*`, `statistics.*`, `filters.selectAccounts`); «Загальний баланс» / «Доходи» / «Витрати» — ключі
      дашборда.
- [ ] Нові: «Усі рахунки», «%lld рахунки» (плюралізація), «%lld операцій» / «%lld груп» (плюралізація), «Немає … за
      цей місяць / рік», підзаголовок про валюту рахунку (`Q-03`), підписи вибраного дня / місяця.

### 6. Перевірка й документація
- [ ] Збірка й тести: `xcodebuild … -scheme Finwaze -destination 'platform=iOS Simulator,name=iPhone 18 Pro' test`.
- [ ] RPC перевірено на локальному Supabase тими самими параметрами (демо-акаунт; з рахунками й без; попередній місяць;
      рік).
- [ ] Екран у симуляторі в демо-режимі (uk): підсумки, огляд, стовпчики, статистика — цифри збігаються з
      демо-операціями й дашбордом за поточний місяць.
- [ ] Критерії приймання ANL-01…06 у симуляторі на локальному Supabase:
  - вибір одного рахунку змінює підсумки, місячний огляд і статистику лише під цей рахунок, а «Бюджети vs Витрати» й
    режим «Бюджет» — ні;
  - «Місячний огляд → Витрати» показує дві лінії: вибраний і попередній місяць;
  - витрата 5 € з гривневого рахунку потрапляє в UAH-аналітику (за сумою списання), а не в EUR;
  - переказ між рахунками не змінює доходів, витрат і статистики, але змінює баланс вибраного рахунку;
  - баланс поточного місяця збігається із «Загальним балансом» дашборда в тій самій валюті;
  - фільтри зберігаються після «Назад» і переходу на інші вкладки; після виходу з акаунта — скинуті;
  - нова операція оновлює Аналітику при поверненні.
- [ ] Dark Mode, Dynamic Type (найбільші розміри — фільтри переносяться, суми не обрізаються), VoiceOver, горизонтальна
      орієнтація.
- [ ] `ios/docs/TECH_DEBT.md`: з «Section placeholders» прибрати Аналітику.
- [ ] Статус плану — «виконано».

## Ключові файли

- Нові: `Features/Analytics/Models/{AnalyticsQuery,AnalyticsSummary,AnalyticsSummaryDto,DailyOverviewPoint,
  DailyOverviewPointDto,MonthlyBudgetExpense,MonthlyBudgetExpenseDto,AnalyticsGroupAmountsDto,AnalyticsFilter,
  SummaryComparison}.swift`, `Features/Analytics/Repositories/{AnalyticsRepository,SupabaseAnalyticsRepository}.swift`,
  `Features/Analytics/Mappers/AnalyticsMapper.swift`, `Features/Analytics/ViewModels/AnalyticsViewModel.swift`,
  `Features/Analytics/Views/{AnalyticsView,AnalyticsFilterBar,AnalyticsSummaryCard,MonthlyOverviewCard,
  BudgetsVsExpensesCard,AnalyticsStatisticsCard}.swift`, `Core/Demo/DemoAnalyticsRepository.swift`,
  `Shared/ViewModels/CardLoader.swift`, `Shared/Models/CurrencySelection.swift`, тести в `ios/FinwazeTests/Analytics/`.
- Змінюються: `Core/Repositories/Repositories.swift`, `Features/Main/Views/{SectionView,MainTabView}.swift`,
  `Features/Wallet/{Models/WalletWidgetFilter,ViewModels/WalletWidgetViewModel}.swift`,
  `Features/Dashboard/Views/SummaryCard.swift`, `Shared/Views/MonthStepper.swift`, `Core/Demo/DemoBudgetRepository.swift`
  (план для року), `Localizable.xcstrings`, `ios/docs/TECH_DEBT.md`.
- Перевикористовуємо: `GroupAmounts`, `BudgetRepository.budgets` / `BudgetQuery`, `SummaryKind`, `TrendChange` /
  `TrendBadge`, `DonutChart` / `SliceSummary`, `CardState` / `ContentCard` / `CardStateView` / `CardEmptyState`,
  `CurrencyFilterMenu`, `FilterChip`, `MonthStepper`, `YearMonth`, `DevicePreferences.primaryCurrencyCode`,
  `ReferenceDataStore.accounts`, графіки за зразком `DailyCashFlowCard` і `CashFlowCard`.
- Джерело поведінки на web: `src/app/features/analytics/**` (`analytics.html`, `stores/analytics-store.ts`,
  `repositories/analytics-repository.ts`, `ui/stats-filters`, `ui/financial-summary-card`,
  `ui/financial-monthly-overview-*`, `ui/budget-expenses-card`, `ui/budgets-expenses-chart`,
  `ui/analytic-statistics-card`), переклади — `src/app/core/i18n/analytics.translations.ts`; SQL:
  `supabase/schemas/charts_funcs.sql` (`get_analytics_*`, `get_daily_financial_overview_for_month`),
  `supabase/schemas/monthly_budgets_funcs.sql` (`get_monthly_budgets_by_groups`, `get_yearly_budgets_vs_expenses`).
