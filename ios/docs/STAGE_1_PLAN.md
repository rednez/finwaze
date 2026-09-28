# iOS — План закриття етапу 1 «Вхід через email і каркас»

> **Статус:** виконано.

Етап 1 з `docs/functional-design.md` (розділ 6): AUTH-02…05, 11, 12 · NAV-01…11 · GEN-15…18.
Результат для користувача: можна зареєструватися, увійти, вийти; видно порожні розділи з навігацією.

## Стан на початку етапу

| Вимога | Стан | Що бракує |
|---|---|---|
| AUTH-02 | ⚠️ | Немає посилання «Забули пароль?» |
| AUTH-03 | ⚠️ | Помилка входу обробляється, але після входу немає маршрутизації за NAV-07/08 |
| AUTH-04, 05 | ✅ | — |
| AUTH-11 | ⚠️ | Сесія завершується, але немає налаштувань на пристрої (GEN-17), які треба очищати |
| AUTH-12 | ✅ | — |
| NAV-01, 02, 04 | ❌ | Немає вкладок, другорядної навігації, меню профілю |
| NAV-03 | ❌ | Немає розділів із заголовком, описом і «?» |
| NAV-05 | — | Форм ще немає; перевіряється на наступних етапах |
| NAV-06 | ✅ | — |
| NAV-07, 08 | ❌ | Немає перевірки «чи є рахунки»; завжди показується `HomePlaceholderView` |
| NAV-09 | ✅ | Заставка — голий `ProgressView`; бажано з логотипом |
| NAV-10, 11 | ❌ | Немає репозиторіїв рахунків / груп і категорій / валют; немає основної валюти |
| GEN-15 | ✅ | en / uk / cs |
| GEN-16 | ✅ | Системна тема (перемикач — NAV-12, етап 15) |
| GEN-17 | ❌ | Немає сховища налаштувань на пристрої |
| GEN-18 | ⚠️ | Немає спільних хелперів форматування грошей і дат |

## Кроки

Порядок: 0 → 1 → 2 → 4 → 3 → 5; кроки 6 і 7 — паралельно.

### 0. Середовища: local / staging / prod

Аналог `src/environments/*` з web (`fileReplacements`) — через конфігурації збірки й `.xcconfig`.

- [x] Три конфігурації збірки: `Debug` → локальний Supabase, `Staging` (копія `Release`) → staging,
      `Release` → prod. Для всіх трьох таргетів (застосунок і тести).
- [x] `ios/Config/{Debug,Staging,Release}.xcconfig` (поза синхронізованою групою `Finwaze/`, щоб не потрапити в ресурси) з `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`,
      `PRODUCT_BUNDLE_IDENTIFIER`, `APP_DISPLAY_NAME`. Значення — ті самі, що в `src/environments/*`.
      URL записувати як `https:/$()/host` (у xcconfig `//` — початок коментаря).
- [x] Файли xcconfig **комітяться**: у них лише publishable-ключі, як і на web.
      Secret і `service_role` ключі — ніколи.
- [x] Окремі bundle id і назви, щоб усі збірки стояли поруч і не ділили Keychain із сесією:
      `dev.yefimenko.Finwaze.dev` / «Finwaze Dev», `dev.yefimenko.Finwaze.staging` / «Finwaze β»,
      `dev.yefimenko.Finwaze` / «Finwaze». Згодом — окремі іконки.
- [x] Info.plist: ключі `SUPABASE_URL = $(SUPABASE_URL)`, `SUPABASE_PUBLISHABLE_KEY = $(SUPABASE_PUBLISHABLE_KEY)`,
      `CFBundleDisplayName = $(APP_DISPLAY_NAME)`.
- [x] `SupabaseConfig.load()` читає значення з `Bundle.main.infoDictionary` замість `Supabase.plist`.
- [x] Видалити `Config/Supabase.plist` (і рядок у `.gitignore`) та `ios/Supabase.example.plist`.
- [x] `WEB_APP_URL` для посилання скидання пароля; для Staging і Release — порожній, поки не відомі домени web (див. `TECH_DEBT.md`).
- [x] Схеми `Finwaze` (Debug / Release) і `Finwaze Staging` (Staging), обидві shared (`xcshareddata`).
- [x] Оновити `ios/CLAUDE.md`: розділ Local Development (схеми, xcconfig замість plist) і критичне правило 4 —
      «publishable-ключі комітяться в xcconfig; secret і `service_role` ключі й матеріали підпису — ніколи».

### 1. Налаштування на пристрої (GEN-17, AUTH-11)

- [x] `Core/Preferences/DevicePreferences` — протокол + реалізація на `UserDefaults`: основна валюта; місця під
      останні рахунок / групу / категорію / валюту для витрати й доходу (заповнюватиме етап 3).
- [x] `clear()` викликається з `SessionStore.signOut()`.
- [x] Зберігати `ownerUserId` і очищати налаштування, якщо входить інший користувач (покриває вихід через
      відхилену сервером сесію, коли `signOut()` не викликається).

### 2. Довідкові дані (NAV-10)

- [x] Моделі, `*Dto`, мапери й репозиторії за протоколами:
  - `AccountsRepository` → `accounts` з `type = 'regular'`, як web `AccountsRepository.getAll` (баланси — у Гаманці, етап 2);
  - `CategoriesRepository` → `groups` / `categories` з `is_system = false`
    (див. `src/app/core/repositories/categories-repository.ts`);
  - `CurrenciesRepository` → `currencies`.
- [x] `ReferenceDataStore` (`@Observable`): завантаження після входу, стани loading / loaded / failed, `reload()`.

### 3. Маршрутизація (NAV-06…09, AUTH-03)

- [x] Стан кореня: `loading → signedOut → onboarding | main | failed`.
- [x] Після входу — заставка, поки вантажаться рахунки; 0 рахунків → Перше знайомство, інакше → головний екран.
- [x] `OnboardingPlaceholderView` лише з дією «Вийти» (ONB-05); тур і створення рахунку — етап 2.
- [x] Стан помилки «Щось пішло не так» з «Повторити» (GEN-25).
- [x] Заставка NAV-09 з логотипом замість голого `ProgressView`.

### 4. Основна валюта (NAV-11)

- [x] Якщо в `DevicePreferences` немає основної валюти або її немає серед валют рахунків — взяти валюту першого
      рахунку й зберегти.

### 5. Каркас застосунку (NAV-01…04)

- [x] `MainTabView`: `TabView` з 5 вкладками (Дашборд, Операції, Гаманець, Бюджет, Цілі), кожна у власному
      `NavigationStack`.
- [x] Другорядна навігація: меню «Більше» (`…`) у панелі навігації кожного розділу відкриває «Групи й категорії»
      та «Аналітику» в стеку поточної вкладки. `TabSection` не підійшов: на iPhone таб-бар вміщує 4 вкладки + «More»,
      тож «Цілі» ховалися б у «More» всупереч NAV-01.
- [x] Спільний `SectionScreen`: заголовок, опис (`.navigationSubtitle`), у toolbar — «?» і кнопка профілю.
      Вміст розділів — порожній стан (`ContentUnavailableView`).
- [x] Меню профілю: email, «Посібник», «Налаштування», «Вийти». Посібник і Налаштування — заглушки (етапи 14–15);
      «?» відкриває заглушку статті.
- [x] Назви й описи розділів — з web i18n, у `Localizable.xcstrings` (en / uk / cs).

### 6. «Забули пароль?» (AUTH-02, мінімальний AUTH-08)

- [x] Посилання на екрані входу через email.
- [x] Екран з полем Email → `resetPasswordForEmail` → «Перевірте пошту… поверніться сюди й увійдіть з новим
      паролем» + дія «Увійти».
- [x] Відкриття застосунку з посилання (AUTH-09) лишається в `TECH_DEBT.md`.

### 7. Форматування (GEN-18)

- [x] `Core/Formatting`: гроші (`Decimal.FormatStyle.Currency`), дата операції з урахуванням `local_offset`,
      місяць. Усе на `Locale.current`. Тести.

### 8. Тести й прибирання

- [x] Тести: маршрутизація (0 рахунків / є рахунки / помилка), очищення налаштувань при виході й зміні
      користувача, вибір основної валюти, мапери.
- [x] Видалити `HomePlaceholderView` і відповідний пункт у `ios/docs/TECH_DEBT.md`.

## Зауваження

- Демо-режим досі входить у спільний серверний акаунт. Для етапу 1 це не проблема, бо зараз застосунок дані
  лише читає, але пункт про демо-режим у `TECH_DEBT.md` треба закрити до етапу 2: створення рахунку вже
  змінюватиме спільні демо-дані.
