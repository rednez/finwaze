# iOS — План етапу 11 «Цілі заощаджень»

> **Статус:** виконано.

## Контекст

Етап 11 з `docs/functional-design.md` (розділ 6): **GOAL-01…26**. Залежить від етапу 5: внесення, зняття, завершення й
скасування цілі — це перекази (`GOAL-03`), а `TransfersRepository.make` уже є. Зараз розділ «Цілі» в другорядній
навігації (`NAV-02`, `Q-13`) показує заглушку «у розробці» (`SectionContentView`), а «Усі цілі» на дашборді ведуть
туди ж (`ios/docs/TECH_DEBT.md`). Уже є модель `SavingsGoal` зі статусом і прогресом, `SavingsGoalDto` і
`SavingsGoalsMapper` (етап 8, картка `DASH-07`) та демо-цілі `DemoData.savingsGoals`. Результат для користувача:
створити ціль, вносити й знімати гроші, бачити прогрес і огляд заощаджень, завершити, скасувати або видалити ціль.

## Рішення

- **Схеми Supabase не змінюються.** Беремо ті самі RPC, що web (`goals-repository.ts`), з
  `supabase/schemas/savings_goals.sql`:
  - `get_savings_goals(p_limit, p_status, p_period_from)` — список (`GOAL-10`): `p_period_from` — `"YYYY-01-01"`
    вибраного року, `p_status` — сирий статус (`not_started`, …) або не передається для «Усі». Цілі новими першими.
    Одна ціль (`GOAL-26`) — той самий виклик з `.eq("id", value:)`, як web; порожньо → `nil`;
  - `get_monthly_savings_overview(p_year, p_currency_code)` — 12 рядків `month` / `current_year_amount` /
    `previous_year_amount`, чисті внески (зняття — мінус, тож сума може бути від'ємною) (`GOAL-16`);
  - `create_savings_goal(p_name, p_currency_id, p_target_amount, p_target_date)` → id рахунку цілі (`GOAL-21`);
  - `update_savings_goal(p_account_id, p_name, p_target_amount, p_target_date)` — валюта не змінюється (`GOAL-20`);
  - `mark_savings_goal_as_done(p_account_id)`, `cancel_savings_goal(p_account_id)`, `delete_savings_goal(p_account_id)`;
  - внесення, зняття та переведення грошей під час завершення / скасування — наявний `TransfersRepository.make`
    (`make_transfer`) з `NewTransfer(toAmount: nil)`: валюти однакові, тож сервер бере ту саму суму (`GOAL-03`).
  Id цілі — це id її рахунку (`SavingsGoal.id`), як і на web.
- **Де живе код.** `Features/Goals` (моделі й мапер уже там):
  - `GoalsRepository` + `SupabaseGoalsRepository`: `goals(_ query: GoalsQuery)`, `goal(id:)`,
    `savingsOverview(year:currencyCode:)`, `create(_ goal: NewSavingsGoal) -> Int64`, `update(id:_:)`,
    `markDone(id:)`, `cancel(id:)`, `delete(id:)`; додається до обох наборів у `Repositories`;
  - моделі: `GoalsQuery` (рік + `SavingsGoalStatus?`), `GoalsSummary` (кількість усього й за статусами, `GOAL-15`),
    `MonthlySavings` + `MonthlySavingsDto`, `NewSavingsGoal` / `SavingsGoalUpdate` + DTO параметрів, `GoalRoute`;
  - `SavingsGoalsMapper` доповнюється `toMonthlySavings` (`month` — `YearMonth`, `null` → 0);
  - `DashboardRepository.recentGoals` лишається як є (той самий RPC з `p_limit`), щоб не чіпати етап 8.
- **Екран «Цілі» (`GOAL-10…17`)** — `GoalsView` + `GoalsViewModel`, замість заглушки в `SectionContentView`:
  - **фільтри** — картка на кшталт `BudgetFilterCard`: рік («‹ 2026 ›»; за замовчуванням поточний) і
    статус (Усі / Не розпочата / В процесі / Досягнута / Скасована). Зміна фільтра перечитує список і огляд;
  - «+» у тулбарі розділу — «Додати ціль» (`AppSection.addTitle` для `.goals`), відкриває sheet «Нова ціль»;
  - **картка цілі (`GOAL-11`)** — `GoalCard`: кольорова позначка статусу (кольори web: «Не розпочата» — бурштиновий,
    «В процесі» — зелений, «Досягнута» — акцентний, «Скасована» — червоний; із назвою статусу текстом, а не лише
    кольором), назва, «Термін – <дата>», «накопичено / ціль» з валютою (`GEN-06`), шкала й відсоток (наявні
    `progressPercent` / `progressFraction`), для «В процесі» — «Залишилось до цілі: <сума>». Натискання → екран цілі
    (`GoalRoute` через `pushRoute`);
  - **дії на картці (`GOAL-12`)** — «Внести» для «Не розпочатої» й «В процесі», «Зняти» — ще й коли накопичено > 0;
  - **«Усього цілей» (`GOAL-15`)** — з уже завантаженого списку (як web), без окремого запиту;
  - **«Огляд заощаджень» (`GOAL-16`)** — Swift Charts, стовпці по 12 місяцях року з фільтра: цей рік проти
    попереднього (як `CashFlowCard`); нульова лінія видна, бо внески бувають від'ємні. Вибір валюти — меню серед валют
    цілей у поточному списку; вибрана лишається, поки вона є серед них, інакше перша. Немає цілей → картка не
    показується. Своя помилка / повтор картки (`CardState`, `GEN-24`);
  - **порожній стан (`GOAL-17`)** — «Поки немає цілей…» + «Додати ціль»; якщо порожньо лише через фільтри —
    «Немає цілей за цими фільтрами» без дії (web тут показує той самий стан, що й без цілей);
  - картки цілей — одна під одною, нижче «Усього цілей» і огляд (адаптивна сітка, як у `DashboardView`: у
    горизонтальній орієнтації стає дві колонки). Перечитується на `app.dataVersion` (`GEN-26`), pull-to-refresh.
- **Внести / Зняти (`GOAL-13`, `GOAL-14`)** — один sheet `GoalTransferView` + `GoalTransferViewModel` з режимом
  `.deposit` / `.withdraw` (за зразком `TransferFormViewModel`):
  - рахунок — звичайні рахунки з `ReferenceDataStore` у валюті цілі («З рахунку» / «На рахунок»); якщо такий один —
    вибраний одразу;
  - сума — `PositiveAmountInput` (> 0, два знаки, `GEN-07`); для зняття ще «Не може перевищувати накопичену суму»;
  - дата й час — за замовчуванням зараз, не в майбутньому (`GEN-13`); `LocalOffset` від пристрою;
  - **немає рахунку у валюті цілі (`Q-04`)** — замість форми пояснення «Немає рахунку в EUR» і дія «Створити рахунок»,
    що відкриває наявний `NewAccountView`; після створення рахунок з'являється у формі (`ReferenceDataStore`);
  - успіх — sheet закривається, банер «Переказ успішний — зараховано на <ціль>» / «Зняття успішне»
    (`SuccessBanner` на екрані «Цілі»); помилка — `failureAlert` з поясненням сервера, введене лишається (`GEN-19`).
- **Нова ціль / редагування (`GOAL-20…22`)** — `GoalFormViewModel` (одна логіка перевірок для обох режимів):
  - **Нова ціль** — sheet з «Цілі»: Назва (обрізані пробіли, 3–30 символів), Цільова сума (`PositiveAmountInput` і
    ≥ 1 — «Має бути не менше 1»), Цільова дата (`DatePicker`, від сьогодні), Валюта (`CurrencyPicker` з повного
    довідника; за замовчуванням основна валюта `preferences.primaryCurrencyCode`). «Створити ціль» → sheet
    закривається, список перечитується (`GOAL-21`);
  - **екран цілі** — `GoalDetailView`, пуш по `GoalRoute(id:)` з «Цілей». Спершу `goal(id:)`: завантаження;
    `nil` → «Ціль не знайдено» + «До цілей» (`GOAL-26`); помилка → «Щось пішло не так» + «Спробувати ще раз»
    (`GEN-25`; web тут показує «не знайдено»). Зверху — підсумок цілі (статус, прогрес, накопичено), нижче форма з
    тими самими полями; валюта — лише для читання. «Зберегти зміни» активна, коли є зміни; успіх — банер
    «Ціль оновлено», ціль перечитується;
  - **цільова дата при редагуванні**: діапазон — від меншої з «сьогодні» й збереженої дати, щоб прострочену ціль можна
    було перейменувати, не змінюючи дату (web так само перевіряє лише, що дата є);
  - **досягнута чи скасована (`GOAL-04`, `GOAL-22`)** — поля лише для читання, дій немає; лишаються тільки підсумок і
    (якщо можна) «Видалити ціль».
- **Дії з ціллю (`GOAL-23…25`)** — секція внизу `GoalDetailView`:
  - **«Позначити досягнутою»** — лише для «Не розпочатої» / «В процесі» при накопичено ≥ цільової суми. Sheet
    «Ціль досягнута! Вітаємо»: сума до переказу (усе накопичене, лише для читання), вибір звичайного рахунку у валюті
    цілі (`Q-04` — як у «Внести»), кнопки «Продовжити заощаджувати» (закрити) і «Завершити ціль»;
  - **«Позначити скасованою»** — для «Не розпочатої» / «В процесі». Накопичено 0 → `confirmationDialog`
    «Позначити ціль скасованою? Цю дію неможливо скасувати» → `cancel(id:)`. Накопичено > 0 → той самий sheet, що й
    завершення, з текстами скасування: сума до повернення й рахунок;
  - **двокрокове завершення / скасування.** Як web: спершу `make_transfer` усього накопиченого з рахунку цілі, потім
    `mark_savings_goal_as_done` / `cancel_savings_goal`. Атомарності немає, тож `GoalClosingViewModel` пам'ятає, який
    крок уже вдався: якщо впав другий, повтор робить лише його (інакше після переказу накопичено 0, і «Позначити
    досягнутою» зникне). Записуємо в `TECH_DEBT.md` пропозицію SQL-функції, що робить обидва кроки в одній транзакції;
  - **«Видалити ціль»** — лише коли `!hasTransfers` (`GOAL-25`); підтвердження «Видалити ціль назавжди?»
    (`GEN-22`). Web пише «усі пов'язані операції теж буде видалено», але без внесків їх немає — текст із вимоги;
  - успіх завершення, скасування чи видалення → назад до «Цілей» з банером; помилка — `failureAlert` (`GEN-19`).
- **Оновлення даних (`GEN-26`).** `AppViewModel.goalsChanged()` → `dataChanged()` після створення, зміни, внесення,
  зняття, завершення, скасування й видалення: перечитуються «Цілі», картка цілей і загальний баланс дашборда, баланси
  Гаманця й список операцій (перекази цілей там видно як перекази).
- **Навігація.** `GoalsView` реєструє `navigationDestination(for: GoalRoute.self)` сам (як `BudgetView` для групи), щоб
  екран цілі міг повернути банер завершення / скасування / видалення на «Цілі». «Усі цілі» й натискання цілі на
  дашборді й далі відкривають «Цілі» (`DASH-07`).
- **Демо (`AUTH-10`).** `DemoGoalsRepository`:
  - `goals` — `DemoData.savingsGoals` з тими самими фільтрами року й статусу; `goal(id:)` — з того ж списку;
  - `savingsOverview` — як web `buildSavingsOverview` (200 + 30·місяць цього року, 150 + 25·місяць минулого) для
    валют демо-цілей, для інших — нулі;
  - `create` повертає вигаданий id (як web — `9999`), `update` / `markDone` / `cancel` / `delete` — no-op з успіхом;
    внесення й зняття йдуть через наявний no-op `DemoTransfersRepository.make`. Банери з'являються, дані не змінюються.
  Демо-рахунки USD і EUR є, тож «Внести» в обидві демо-цілі має звідки.

## Кроки

### 1. Дані
- [x] `GoalsQuery`, `NewSavingsGoal`, `SavingsGoalUpdate` + DTO параметрів, `MonthlySavings` + `MonthlySavingsDto`,
      `GoalsSummary`, `GoalRoute`; `SavingsGoalsMapper.toMonthlySavings`.
- [x] `GoalsRepository` + `SupabaseGoalsRepository` (усі RPC вище; дата — `"YYYY-MM-DD"` у часовому поясі пристрою, як
      `targetDate` читається).
- [x] `DemoGoalsRepository`; `Repositories.live` / `.demo` отримують `goals`.
- [x] Тести: мапер огляду (`null` → 0, від'ємні внески); кодування параметрів створення / зміни (дата як календарний
      день без зсуву поясу, сума без втрати точності, `GEN-09`); демо — фільтр року й статусу, ціль за id, огляд.

### 2. ViewModel-и
- [x] `GoalsViewModel`: фільтри, стани списку й огляду, `GoalsSummary`, валюти огляду й вибір валюти, дії картки
      (`canDeposit`, `canWithdraw`), банер після внесення / зняття.
- [x] `GoalTransferViewModel` (`.deposit` / `.withdraw`): рахунки у валюті цілі, перевірка суми й дати, межа
      накопиченого для зняття, `NewTransfer` в потрібному напрямку.
- [x] `GoalFormViewModel`: створення й редагування, перевірки `GOAL-20`, діапазон дати, `isDirty`, лише читання для
      досягнутої / скасованої.
- [x] `GoalDetailViewModel` + `GoalClosingViewModel`: завантаження / не знайдено / помилка, доступність дій
      `GOAL-23…25`, двокрокове завершення / скасування з повтором лише невдалого кроку, видалення.
- [x] Тести: зміна року / статусу надсилає правильний `GoalsQuery`; підсумок за статусами; «Зняти» лише при
      накопичено > 0; внесок іде з рахунку в ціль, зняття — навпаки, лише рахунки у валюті цілі; зняття більше
      накопиченого не надсилається; назва 2 / 31 символ, сума 0.5, дата вчора — помилки; прострочена дата без змін
      при редагуванні — дозволено; «Позначити досягнутою» лише при накопичено ≥ цілі; скасування з 0 — без переказу;
      падіння другого кроку завершення → повтор без повторного переказу; видалення недоступне при `hasTransfers`;
      `nil` з `goal(id:)` → «не знайдено».

### 3. Екрани й навігація
- [x] `GoalsView` (фільтри, картки, «Усього цілей», «Огляд заощаджень», порожні стани, банер) замість заглушки;
      «+» розділу — «Додати ціль».
- [x] `GoalCard`, `GoalStatusBadge`, `GoalsSummaryCard`, `SavingsOverviewCard` (Swift Charts).
- [x] `GoalTransferView` з поясненням `Q-04` і переходом до `NewAccountView`.
- [x] `NewGoalView` (sheet), `GoalDetailView` (пуш; «не знайдено» — `ContentUnavailableView` усередині),
      `GoalClosingSheet` (завершення / скасування з переказом), спільні `GoalFormFields` і `GoalAccountField`.
- [x] `SectionView` показує `GoalsView`; `GoalsView` — `navigationDestination(for: GoalRoute.self)`;
      `AppViewModel.goalsChanged()`. `FilterChip` перенесено з `BudgetFilterCard` у `Shared/Views`, форматування суми для
      поля (`Decimal.inputText`) — з `AccountSettingsViewModel` у `MoneyFormatting`.
- [x] VoiceOver: картка цілі одним описом (назва, статус, накопичено з ціллю, відсоток, термін), дії «Внести» /
      «Зняти» — окремими елементами; графік — `accessibilityChartDescriptor` або опис по місяцях.

### 4. Локалізація (en / uk / cs)
- [x] Тексти з web (`goals.*`: фільтри й статуси, `editGoal.*`, `transferSuccessful`, `depositedTo`,
      `withdrawalSuccessful`, діалоги завершення / скасування / зняття) — і ті, що на web лише англійською (`Q-09`):
      «New Goal», підтвердження скасування й видалення, «Goal updated successfully», помилки створення / зміни /
      завершення / скасування / видалення.
- [x] Нові: «Немає рахунку в %@» / «Створити рахунок» (`Q-04`), «Немає цілей за цими фільтрами», «Має бути не
      менше 1», «Не може перевищувати накопичену суму», «Ціль не знайдено» / «До цілей», VoiceOver-описи.

### 5. Перевірка й документація
- [x] Збірка й тести: `xcodebuild … -scheme Finwaze -destination 'platform=iOS Simulator,name=iPhone 18 Pro' test`.
- [x] RPC перевірено на локальному Supabase тими самими параметрами: список із `p_period_from` / `p_status`, ціль через
      `?id=eq.`, огляд, створення (скалярний id), зміна, видалення.
- [ ] Критерії приймання GOAL у симуляторі на локальному Supabase:
  - нова ціль «Відпустка, 30 000 ₴» — «Не розпочата»; внесок 5 000 ₴ з гривневого рахунку → «В процесі», 16 %,
    баланс рахунку в Гаманці менший на 5 000 ₴, доходи й витрати на дашборді не змінились;
  - «Внести» в ціль у EUR пропонує лише рахунки в EUR; без такого рахунку — пояснення й створення рахунку;
  - зняти більше, ніж накопичено, неможливо;
  - після накопичення цільової суми з'являється «Позначити досягнутою»; завершення переводить гроші на вибраний рахунок,
    ціль — «Досягнута» й лише для читання;
  - скасування з накопиченим повертає гроші на вибраний рахунок; без накопиченого — лише підтвердження;
  - ціль із хоча б одним внеском не має «Видалити», лише «Позначити скасованою»;
  - фільтр року ховає цілі з терміном до 1 січня року; фільтр статусу й «Усього цілей» узгоджені;
  - огляд заощаджень показує внесок і зняття в правильних місяцях, валюта перемикається;
  - демо: внесення, створення й завершення показують успіх, але дані після перезапуску ті самі.
- [ ] Dark Mode, Dynamic Type (найбільші розміри — картка цілі й дії переносяться), VoiceOver.
- [x] `ios/docs/TECH_DEBT.md`: у «Section placeholders» прибрати Цілі й речення про «Усі цілі»; додати
      «Завершення й скасування цілі не атомарні» (переказ і позначка — два запити; одна SQL-функція виправила б для
      всіх клієнтів).
- [x] Статус плану — «виконано».

## Ключові файли

- Нові: `Features/Goals/Models/{GoalsQuery,GoalsSummary,MonthlySavings,MonthlySavingsDto,NewSavingsGoal,
  SavingsGoalUpdate,GoalRoute}.swift`, `Features/Goals/Repositories/{GoalsRepository,SupabaseGoalsRepository}.swift`,
  `Features/Goals/ViewModels/{GoalsViewModel,GoalTransferViewModel,GoalFormViewModel,GoalDetailViewModel,
  GoalClosingViewModel}.swift`, `Features/Goals/Views/{GoalsView,GoalsFilterCard,GoalCard,GoalStatusBadge,GoalsSummaryCard,
  SavingsOverviewCard,GoalTransferView,GoalAccountField,GoalFormFields,NewGoalView,GoalDetailView,
  GoalClosingSheet}.swift`, `Features/Goals/Models/GoalFormMessages.swift`, `Shared/Views/FilterChip.swift`,
  `Core/Demo/DemoGoalsRepository.swift`, тести й `FakeGoalsRepository` в `ios/FinwazeTests/Goals/`.
- Змінюються: `Features/Goals/Mappers/SavingsGoalsMapper.swift`, `Core/Repositories/Repositories.swift`,
  `Features/Main/Models/AppSection.swift` (`addTitle`), `Features/Main/Views/SectionView.swift`,
  `App/AppViewModel.swift`, `Core/Demo/DemoData+Dashboard.swift` (якщо демо-огляду потрібні дані),
  `Localizable.xcstrings`, `ios/docs/TECH_DEBT.md`.
- Перевикористовуємо: `SavingsGoal` (`progressPercent`, `progressFraction`), `TransfersRepository` / `NewTransfer`,
  `PositiveAmountInput`, `LocalOffset`, `CurrencyPicker`, `NewAccountView`, `SuccessBanner`, `failureAlert`,
  `CardState` / `ContentCard`, `YearMonth`, графік за зразком `CashFlowCard`, форма за зразком `TransferView`.
- Джерело поведінки на web: `src/app/features/goals/**` (`pages/goals`, `pages/edit-goal`, `ui/*-dialog`,
  `stores/goals-list-store.ts`, `stores/savings-overview-store.ts`, `repositories/goals-repository.ts`), демо —
  `src/app/core/services/demo-mode/demo-data.ts`; SQL: `supabase/schemas/savings_goals.sql`,
  `supabase/schemas/transfers_funcs.sql`.
