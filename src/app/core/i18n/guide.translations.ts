export const GUIDE_TRANSLATIONS = {
  en: {
    tipsLabel: 'Best practices',
    backToGuide: 'All guides',
    readCta: 'Read guide',
    hub: {
      eyebrow: 'Guide & tips',
      title: 'Learn Finwaze in a few minutes',
      lead: 'New to tracking your money? These short, practical guides walk you through every part of the app step by step — no finance background needed. Read them in any order, or open the "?" next to any section title to jump straight to its guide.',
      quickStart: {
        title: 'What to do right after signing up',
        steps: [
          'You already created your first account during setup — that is where your money lives in Finwaze.',
          'Open Transactions and record what you spend and earn. A minute a day is enough.',
          'Tidy up your categories so each expense lands in a place that makes sense to you.',
          'When you feel ready, set a budget and create a savings goal — both are optional and can wait.',
        ],
      },
      topicsTitle: 'A guide for every section',
    },
    topics: {
      dashboard: {
        card: {
          title: 'Dashboard',
          summary:
            'Your financial home screen — this month’s money at a glance.',
        },
        eyebrow: 'Your overview',
        title: 'The Dashboard',
        lead: 'The Dashboard is the first thing you see when you open Finwaze: a snapshot of your money this month — how much came in, how much went out, and what is left. It gathers everything from the other sections so you can check where you stand in just a few seconds.',
        sections: [
          {
            heading: 'What the Dashboard shows',
            body: 'At the top you see summary cards for the month: total income, total expenses, and the difference between them. Below that you find your recent activity and the categories you have spent the most on. Only real income and expenses are counted here — money moved between your own accounts is left out, so the figures reflect genuine earning and spending.',
          },
          {
            heading: 'Reading it at a glance',
            body: 'If income is higher than expenses, you ended the period ahead — you saved money. If expenses are higher, you spent more than you earned, which is fine occasionally but worth watching. Think of the Dashboard as a daily or weekly check-in rather than something to study for a long time.',
          },
          {
            heading: 'Where the numbers come from',
            body: 'Everything on the Dashboard is built automatically from the transactions you record. There is nothing to fill in here directly — the more consistently you log transactions, the more accurate and useful this overview becomes.',
          },
        ],
        tips: [
          'Glance at the Dashboard each day, or at least once a week — it is the fastest way to stay aware of your money.',
          'If a number looks off, it usually means a transaction is missing or sits in the wrong category. Fix it in the Transactions section.',
          'Transfers between your own accounts are excluded here on purpose, so the totals always show your real income and spending.',
        ],
      },
      transactions: {
        card: {
          title: 'Track your spending',
          summary:
            'The heart of Finwaze: record what comes in and what goes out.',
        },
        eyebrow: 'The essentials',
        title: 'Transactions',
        lead: 'Transactions are the heart of Finwaze. The easiest way to start is to simply write down your money as it moves — every other section is built from this. You do not need a budget or any setup first: just record income and expenses, and Finwaze turns them into a clear picture of where your money goes.',
        sections: [
          {
            heading: 'What is a transaction?',
            body: 'A transaction is a single movement of money. An expense is money leaving an account (a coffee, rent, groceries). Income is money coming in (salary, a refund, a gift). Every time money moves, you add one transaction — that is the whole idea.',
          },
          {
            heading: 'Recording an expense',
            body: 'Go to Transactions and add a new one. Pick "expense", type the amount, choose the account you paid from, and assign a category (for example "Groceries"). Add the date and an optional note. Save — your account balance updates automatically. Income works the same way; just pick "income".',
          },
          {
            heading: 'Spending in another currency',
            body: 'Paid in a foreign currency? Finwaze keeps both numbers: the transaction amount (what the price tag said, e.g. 5 EUR) and the charged amount (what actually left your account in its own currency, e.g. 130 UAH). You only enter what you see — no manual conversion needed.',
          },
          {
            heading: 'Transfers are not expenses',
            body: 'Moving money between your own accounts — withdrawing cash, paying a card, topping up savings — is a transfer, not an expense. Record it as a transfer so it does not inflate your spending. Your total wealth has not changed, only its location.',
          },
        ],
        tips: [
          'Record transactions the moment they happen, or once at the end of each day, so nothing is forgotten.',
          'Use the same category for the same kind of expense every time — consistency is what makes your reports trustworthy.',
          'Do not log moving money between your own accounts as an expense. That is a transfer, and it should not count as spending.',
          'Review your week every Sunday. Five minutes is enough to notice surprises and stay in control.',
        ],
      },
      categories: {
        card: {
          title: 'Groups & categories',
          summary:
            'Organise transactions into a structure that matches your life.',
        },
        eyebrow: 'Organise',
        title: 'Groups & categories',
        lead: 'Categories are the labels you put on each transaction; groups bundle related categories together. Good structure is what turns a plain list of transactions into reports you can actually learn from — it is worth a few minutes to get it close to your real life.',
        sections: [
          {
            heading: 'Groups versus categories',
            body: 'A group is a broad area of your life — for example "Car". A category is a specific item inside it — "Fuel", "Insurance", "Repairs". Every transaction gets exactly one category, and that category belongs to a group. So "Fuel → Car" tells you both the detail and the bigger picture.',
          },
          {
            heading: 'Setting up your categories',
            body: 'Finwaze comes with a ready-made set of groups and categories, so you can start recording immediately. Over time, rename them, add what is missing, and remove what you never use, until the structure mirrors how you actually live and spend. There is no single correct setup — only the one that fits you.',
          },
          {
            heading: 'Why it matters',
            body: 'Budgets and Analytics are only as clear as your categories. If the same kind of expense always lands in the same category, your reports stay meaningful; if it is scattered, the numbers blur. Consistency here pays off everywhere else.',
          },
        ],
        tips: [
          'Start with the built-in categories and adjust gradually — do not try to design a perfect structure on day one.',
          'Fewer, clearer categories beat dozens of overlapping ones. If you never look at a category, merge it into another.',
          'Keep one "Other" category for rare things — but if it grows large, that is a sign a new category is needed.',
          'Some categories are reserved by Finwaze for transfers and balance adjustments; these are managed for you and stay hidden.',
        ],
      },
      wallet: {
        card: {
          title: 'Understand the Wallet',
          summary:
            'Your accounts in any currency — bank, cash, cards and savings, all in one place.',
        },
        eyebrow: 'Your accounts',
        title: 'The Wallet',
        lead: 'The Wallet is the home of all your accounts. An account in Finwaze mirrors a real place your money sits — a bank account, a cash stash, a card, or a savings pot. You can create as many as you like, each in its own currency, and the Wallet always shows the balance of each one.',
        sections: [
          {
            heading: 'What the Wallet is',
            body: 'The Wallet lists every account you own with its current balance. Each transaction you record belongs to one account and changes its balance. Keeping your accounts here in step with real life is what makes every total in Finwaze accurate.',
          },
          {
            heading: 'As many accounts and currencies as you need',
            body: 'There is no limit. Create separate accounts for your bank, your wallet cash, each card, and any savings — and give each one whatever currency it really uses (UAH, EUR, USD, CZK, and more). When you spend abroad, Finwaze stores both the original price and the amount charged to your account, so multi-currency life just works.',
          },
          {
            heading: 'Moving money between accounts',
            body: 'Withdrawing cash, paying a card, or topping up savings means moving money between your own accounts. That is a transfer, not an expense — it leaves your total wealth unchanged. Finwaze keeps transfers out of your spending reports so your expense figures stay honest.',
          },
        ],
        tips: [
          'Set up one account for each real place you keep money. The closer the Wallet mirrors reality, the more useful every report becomes.',
          'When you add an account, set its current balance as the starting point so figures match your bank from day one.',
          'Keep a separate cash account — small cash spending is the easiest to lose track of.',
          'Pick one main currency you think in day to day; let the others simply reflect the accounts that use them.',
          'Use savings-goal accounts to ring-fence money you do not want to spend by accident.',
        ],
      },
      budget: {
        card: {
          title: 'Build a budget',
          summary:
            'Set monthly limits per category and stop overspending before it happens.',
        },
        eyebrow: 'Plan ahead',
        title: 'Budgets',
        lead: 'A budget is simply a plan for how much you intend to spend in each category during a month. It is not about restricting yourself — it is about deciding where your money should go before it disappears, so the end of the month holds no surprises.',
        sections: [
          {
            heading: 'What a budget is',
            body: 'A budget assigns a monthly spending limit to a category — for example, 4,000 UAH for "Groceries" or 1,000 UAH for "Eating out". As you record expenses, Finwaze compares them against these limits so you always know how much room is left.',
          },
          {
            heading: 'Setting your first budget',
            body: 'Open the Budget section, pick a category, and enter the amount you want to spend on it this month. Start with just two or three categories you care about most — you can always add more later. There is no need to budget every category from day one.',
          },
          {
            heading: 'Tracking your progress',
            body: 'Each budget shows a progress bar that fills as you spend. Green means you are on track; as you approach the limit it warns you, so you can adjust before you overspend rather than discovering it afterwards. Budgets reset at the start of each month.',
          },
        ],
        tips: [
          'Base your limits on reality, not hope. Track for a month first, check Analytics, then set limits close to what you actually spend.',
          'Begin with a few categories. A budget you can follow beats a perfect one you abandon after a week.',
          'Leave a small buffer category for the unexpected — there is always something.',
          'A simple starting point is the 50/30/20 idea: roughly 50% of income on needs, 30% on wants, 20% on saving and debt.',
          'Revisit your budget at the start of each month and adjust limits as your life changes.',
        ],
      },
      goals: {
        card: {
          title: 'Reach savings goals',
          summary:
            'Save toward something specific and watch your progress grow.',
        },
        eyebrow: 'Save with purpose',
        title: 'Savings goals',
        lead: 'A savings goal turns a vague wish ("I should save more") into a concrete target you can actually reach — a holiday, an emergency fund, a new laptop. Finwaze gives each goal its own account so the money stays separate and your progress is always visible.',
        sections: [
          {
            heading: 'What a savings goal is',
            body: 'A goal is a target amount you want to set aside — say, 30,000 UAH for a trip. It is backed by a dedicated savings account, so the money you set aside for it is kept apart from your everyday spending and is not accidentally used up.',
          },
          {
            heading: 'Creating a goal',
            body: 'Open the Goals section and create one: give it a name, a target amount, and a currency. Finwaze sets up a savings account for it. From that moment you have a clear finish line to aim at.',
          },
          {
            heading: 'Funding and tracking',
            body: 'To put money toward a goal, transfer it from your everyday account into the goal’s savings account. A transfer moves money between your own accounts without counting as spending. The goal’s progress bar grows with every contribution, showing how close you are to the target.',
          },
        ],
        tips: [
          'Build an emergency fund first — three to six months of expenses — before saving for nice-to-haves. It is the goal that protects all the others.',
          'Pay yourself first: move money into your goal right after payday, before you spend on anything else.',
          'Give each goal one clear purpose. Separate goals are easier to stay motivated for than one big vague pile.',
          'Even small, regular contributions add up faster than you expect. Consistency beats size.',
        ],
      },
      analytics: {
        card: {
          title: 'Analytics',
          summary: 'See the trends and patterns behind your spending.',
        },
        eyebrow: 'Insights',
        title: 'Analytics',
        lead: 'Analytics is where your day-to-day transactions become insight. Instead of single numbers, you see how your money behaves over time and across categories — so you can make decisions based on facts rather than guesses.',
        sections: [
          {
            heading: 'What you can see',
            body: 'Analytics breaks your money down by category and group, and shows income against expenses across several months. At a glance you can tell where the biggest chunks of your money go and how your spending changes from month to month.',
          },
          {
            heading: 'Using it to understand yourself',
            body: 'Look for your largest categories and any months that ran unusually high. These are the facts that explain where your money actually goes — often quite different from where we assume it goes. No judgement, just a clearer mirror.',
          },
          {
            heading: 'Turning insight into action',
            body: 'Analytics tells you what already happened; Budgets help you plan what should happen next. Use them together: study your real spending here, then set budget limits that are realistic because they are based on your own numbers.',
          },
        ],
        tips: [
          'Before setting any budget, look at Analytics first — base your limits on what you really spend, not on a guess.',
          'Watch trends across several months, not a single one. One unusual month is not a pattern.',
          'Your biggest categories are where small percentage savings make the biggest difference — focus your attention there.',
          'The more consistently you categorise transactions, the more trustworthy Analytics becomes.',
        ],
      },
    },
  },
  uk: {
    tipsLabel: 'Найкращі практики',
    backToGuide: 'Усі посібники',
    readCta: 'Читати',
    hub: {
      eyebrow: 'Посібник і поради',
      title: 'Опануйте Finwaze за кілька хвилин',
      lead: 'Тільки починаєте вести облік грошей? Ці короткі практичні посібники крок за кроком пояснюють кожну частину застосунку — без жодної фінансової освіти. Читайте в будь-якому порядку або натисніть «?» біля заголовка розділу, щоб одразу перейти до його посібника.',
      quickStart: {
        title: 'Що робити одразу після реєстрації',
        steps: [
          'Перший рахунок ви вже створили під час налаштування — саме там у Finwaze зберігаються ваші гроші.',
          'Відкрийте «Транзакції» та записуйте, що витрачаєте і отримуєте. Достатньо хвилини на день.',
          'Упорядкуйте категорії, щоб кожна витрата потрапляла туди, де вам це зрозуміло.',
          'Коли будете готові, складіть бюджет і створіть ціль заощаджень — це не обов’язково й може зачекати.',
        ],
      },
      topicsTitle: 'Посібник для кожного розділу',
    },
    topics: {
      dashboard: {
        card: {
          title: 'Дашборд',
          summary:
            'Ваш фінансовий головний екран — гроші за місяць з першого погляду.',
        },
        eyebrow: 'Ваш огляд',
        title: 'Дашборд',
        lead: 'Дашборд — перше, що ви бачите, відкриваючи Finwaze: знімок ваших грошей цього місяця — скільки надійшло, скільки пішло й що залишилось. Він збирає все з інших розділів, тож ви оцінюєте свій стан за кілька секунд.',
        sections: [
          {
            heading: 'Що показує Дашборд',
            body: 'Угорі — підсумкові картки за місяць: загальний дохід, загальні витрати і різниця між ними. Нижче — нещодавня активність і категорії, на які ви витратили найбільше. Тут рахуються лише реальні доходи та витрати — переміщення між вашими рахунками не враховуються, тож цифри відображають справжні заробіток і витрати.',
          },
          {
            heading: 'Як читати з першого погляду',
            body: 'Якщо дохід більший за витрати, період завершено в плюс — ви заощадили. Якщо витрати більші, ви витратили більше, ніж заробили: інколи це нормально, але варто стежити. Сприймайте Дашборд як щоденну чи щотижневу звірку, а не як те, що потрібно довго вивчати.',
          },
          {
            heading: 'Звідки беруться цифри',
            body: 'Усе на Дашборді будується автоматично з записаних вами транзакцій. Тут нічого не треба заповнювати напряму — що послідовніше ви фіксуєте транзакції, то точнішим і кориснішим стає цей огляд.',
          },
        ],
        tips: [
          'Зазирайте на Дашборд щодня або хоча б раз на тиждень — це найшвидший спосіб тримати гроші у полі зору.',
          'Якщо цифра виглядає дивно, зазвичай бракує транзакції або вона в неправильній категорії. Виправте це в розділі «Транзакції».',
          'Перекази між вашими рахунками тут навмисно не враховуються, тож підсумки завжди показують справжні доходи й витрати.',
        ],
      },
      transactions: {
        card: {
          title: 'Облік витрат',
          summary: 'Серце Finwaze: записуйте, що приходить і що йде.',
        },
        eyebrow: 'Основи',
        title: 'Транзакції',
        lead: 'Транзакції — серце Finwaze. Найлегше почати — просто записувати рух своїх грошей, адже всі інші розділи будуються саме на цьому. Вам не потрібен ані бюджет, ані налаштування: фіксуйте доходи та витрати, а Finwaze перетворить їх на чітку картину того, куди йдуть ваші гроші.',
        sections: [
          {
            heading: 'Що таке транзакція?',
            body: 'Транзакція — це один рух грошей. Витрата — це гроші, що залишають рахунок (кава, оренда, продукти). Дохід — гроші, що надходять (зарплата, повернення, подарунок). Щоразу, коли гроші рухаються, ви додаєте одну транзакцію — ось і вся ідея.',
          },
          {
            heading: 'Як записати витрату',
            body: 'Перейдіть у «Транзакції» й додайте нову. Оберіть «витрата», введіть суму, виберіть рахунок, з якого платили, і призначте категорію (наприклад, «Продукти»). Додайте дату й за бажанням нотатку. Збережіть — баланс рахунку оновиться автоматично. Дохід працює так само: оберіть «дохід».',
          },
          {
            heading: 'Витрати в іншій валюті',
            body: 'Платили в іноземній валюті? Finwaze зберігає обидва числа: суму транзакції (те, що на ціннику, напр. 5 EUR) і списану суму (те, що насправді пішло з рахунку у його валюті, напр. 130 UAH). Ви вводите лише те, що бачите — конвертувати вручну не потрібно.',
          },
          {
            heading: 'Перекази — це не витрати',
            body: 'Переміщення грошей між вашими рахунками — зняття готівки, погашення картки, поповнення заощаджень — це переказ, а не витрата. Записуйте його як переказ, щоб не роздувати витрати. Ваш загальний статок не змінився, змінилося лише його місце.',
          },
        ],
        tips: [
          'Записуйте транзакції одразу, щойно вони стаються, або раз наприкінці дня, щоб нічого не забути.',
          'Щоразу використовуйте ту саму категорію для того самого типу витрат — саме послідовність робить звіти надійними.',
          'Не записуйте переміщення грошей між власними рахунками як витрату. Це переказ, і він не має рахуватися витратою.',
          'Переглядайте свій тиждень щонеділі. П’яти хвилин досить, щоб помітити несподіванки й тримати все під контролем.',
        ],
      },
      categories: {
        card: {
          title: 'Групи та категорії',
          summary:
            'Упорядкуйте транзакції у структуру, що відповідає вашому життю.',
        },
        eyebrow: 'Упорядкування',
        title: 'Групи та категорії',
        lead: 'Категорії — це позначки, які ви ставите на кожну транзакцію; групи об’єднують споріднені категорії. Саме хороша структура перетворює простий перелік транзакцій на звіти, з яких справді можна вчитися, — варто кількох хвилин, щоб наблизити її до реального життя.',
        sections: [
          {
            heading: 'Групи проти категорій',
            body: 'Група — це широка сфера життя, наприклад «Авто». Категорія — конкретна стаття всередині неї: «Пальне», «Страхування», «Ремонт». Кожна транзакція отримує рівно одну категорію, а категорія належить групі. Тож «Пальне → Авто» показує і деталь, і ширшу картину.',
          },
          {
            heading: 'Налаштування категорій',
            body: 'Finwaze має готовий набір груп і категорій, тож записувати можна одразу. З часом перейменовуйте їх, додавайте відсутнє та прибирайте те, чим не користуєтесь, доки структура не відобразить, як ви насправді живете й витрачаєте. Єдино правильного варіанту немає — лише той, що пасує вам.',
          },
          {
            heading: 'Чому це важливо',
            body: 'Бюджети й «Аналітика» настільки ж зрозумілі, наскільки ваші категорії. Якщо однаковий тип витрат завжди потрапляє в одну категорію, звіти лишаються змістовними; якщо ж він розсіяний — цифри розмиваються. Послідовність тут окупається всюди.',
          },
        ],
        tips: [
          'Почніть з вбудованих категорій і коригуйте поступово — не намагайтеся створити ідеальну структуру з першого дня.',
          'Менше чітких категорій краще за десятки тих, що перетинаються. Якщо ви ніколи не дивитесь на категорію — об’єднайте її з іншою.',
          'Тримайте одну категорію «Інше» для рідкісного — але якщо вона розростається, це сигнал, що потрібна нова категорія.',
          'Деякі категорії зарезервовані Finwaze для переказів і коригувань балансу; ними керує застосунок, і вони лишаються прихованими.',
        ],
      },
      wallet: {
        card: {
          title: 'Розділ «Гаманець»',
          summary:
            'Ваші рахунки в будь-якій валюті — банк, готівка, картки та заощадження в одному місці.',
        },
        eyebrow: 'Ваші рахунки',
        title: 'Гаманець',
        lead: '«Гаманець» — це дім усіх ваших рахунків. Рахунок у Finwaze відображає реальне місце, де лежать ваші гроші, — банківський рахунок, готівку, картку чи скарбничку заощаджень. Ви можете створити їх скільки завгодно, кожен у своїй валюті, і «Гаманець» завжди показує баланс кожного.',
        sections: [
          {
            heading: 'Що таке «Гаманець»',
            body: '«Гаманець» перелічує всі ваші рахунки з поточним балансом. Кожна записана транзакція належить одному рахунку і змінює його баланс. Саме підтримання рахунків тут у відповідності з реальним життям робить кожен підсумок у Finwaze точним.',
          },
          {
            heading: 'Скільки завгодно рахунків і валют',
            body: 'Обмежень немає. Створюйте окремі рахунки для банку, готівки в гаманці, кожної картки та будь-яких заощаджень — і задавайте кожному ту валюту, якою він насправді користується (UAH, EUR, USD, CZK тощо). Коли витрачаєте за кордоном, Finwaze зберігає і початкову ціну, і списану з рахунку суму, тож мультивалютне життя просто працює.',
          },
          {
            heading: 'Переміщення грошей між рахунками',
            body: 'Зняти готівку, погасити картку чи поповнити заощадження — це переміщення грошей між вашими рахунками. Це переказ, а не витрата: ваш загальний статок не змінюється. Finwaze не включає перекази у звіти про витрати, тож цифри витрат лишаються чесними.',
          },
        ],
        tips: [
          'Створіть по рахунку на кожне реальне місце, де тримаєте гроші. Що ближче «Гаманець» до реальності, то кориснішим стає кожен звіт.',
          'Додаючи рахунок, задайте його поточний баланс як відправну точку, щоб цифри збігалися з банком із першого дня.',
          'Тримайте окремий готівковий рахунок — дрібні готівкові витрати найлегше загубити.',
          'Оберіть одну основну валюту, в якій думаєте щодня; решта нехай просто відображає рахунки, що ними користуються.',
          'Використовуйте рахунки цілей, щоб відгородити гроші, які не хочете витратити випадково.',
        ],
      },
      budget: {
        card: {
          title: 'Складання бюджету',
          summary:
            'Встановіть місячні ліміти за категоріями й зупиняйте перевитрати завчасно.',
        },
        eyebrow: 'Плануйте наперед',
        title: 'Бюджет',
        lead: 'Бюджет — це просто план, скільки ви маєте намір витратити в кожній категорії протягом місяця. Це не про обмеження себе, а про те, щоб вирішити, куди підуть гроші, ще до того, як вони зникнуть, — і тоді кінець місяця не принесе несподіванок.',
        sections: [
          {
            heading: 'Що таке бюджет',
            body: 'Бюджет призначає категорії місячний ліміт витрат — наприклад, 4 000 UAH на «Продукти» чи 1 000 UAH на «Кафе». Коли ви записуєте витрати, Finwaze звіряє їх із цими лімітами, тож ви завжди знаєте, скільки ще залишилося.',
          },
          {
            heading: 'Перший бюджет',
            body: 'Відкрийте розділ «Бюджет», оберіть категорію і введіть суму, яку хочете витратити на неї цього місяця. Почніть лише з двох-трьох найважливіших категорій — решту завжди можна додати пізніше. Не обов’язково планувати все з першого дня.',
          },
          {
            heading: 'Відстеження прогресу',
            body: 'Кожен бюджет показує смужку прогресу, що заповнюється з витратами. Зелений — ви в межах; коли наближаєтеся до ліміту, з’являється попередження, тож ви скоригуєте витрати завчасно, а не дізнаєтеся постфактум. Бюджети оновлюються на початку кожного місяця.',
          },
        ],
        tips: [
          'Встановлюйте ліміти за реальністю, а не за надією. Спершу ведіть облік місяць, перегляньте «Аналітику», а потім задайте ліміти, близькі до фактичних витрат.',
          'Почніть з кількох категорій. Бюджет, якого ви дотримуєтеся, кращий за ідеальний, який кинете за тиждень.',
          'Залиште невелику категорію-буфер на непередбачене — воно завжди є.',
          'Простий старт — правило 50/30/20: приблизно 50% доходу на потреби, 30% на бажання, 20% на заощадження та борги.',
          'Переглядайте бюджет на початку кожного місяця й коригуйте ліміти зі змінами у житті.',
        ],
      },
      goals: {
        card: {
          title: 'Цілі заощаджень',
          summary:
            'Збирайте на щось конкретне й спостерігайте, як росте прогрес.',
        },
        eyebrow: 'Заощаджуйте з метою',
        title: 'Цілі заощаджень',
        lead: 'Ціль заощаджень перетворює розпливчасте бажання («треба більше відкладати») на конкретну мету, якої справді можна досягти, — відпустка, фінансова подушка, новий ноутбук. Finwaze дає кожній цілі окремий рахунок, тож гроші лишаються відокремленими, а прогрес — завжди на видноті.',
        sections: [
          {
            heading: 'Що таке ціль заощаджень',
            body: 'Ціль — це сума, яку ви хочете відкласти, скажімо, 30 000 UAH на подорож. Її підтримує окремий ощадний рахунок, тож відкладені гроші тримаються осторонь від щоденних витрат і не витрачаються випадково.',
          },
          {
            heading: 'Створення цілі',
            body: 'Відкрийте розділ «Цілі» та створіть нову: дайте їй назву, цільову суму й валюту. Finwaze створить для неї ощадний рахунок. Відтоді у вас є чітка фінішна межа, до якої прямувати.',
          },
          {
            heading: 'Поповнення та відстеження',
            body: 'Щоб скерувати гроші до цілі, перекажіть їх зі щоденного рахунку на ощадний рахунок цілі. Переказ переміщує гроші між вашими рахунками, не рахуючись витратою. Смужка прогресу цілі росте з кожним внеском, показуючи, наскільки ви близько до мети.',
          },
        ],
        tips: [
          'Спершу створіть фінансову подушку — на три-шість місяців витрат — перш ніж збирати на приємне. Це ціль, що захищає всі інші.',
          'Платіть собі першими: переказуйте гроші до цілі одразу після зарплати, ще до інших витрат.',
          'Давайте кожній цілі одне чітке призначення. Окремі цілі легше мотивують, ніж одна велика розмита купа.',
          'Навіть малі регулярні внески накопичуються швидше, ніж здається. Регулярність важливіша за розмір.',
        ],
      },
      analytics: {
        card: {
          title: 'Аналітика',
          summary: 'Побачте тренди й закономірності за вашими витратами.',
        },
        eyebrow: 'Інсайти',
        title: 'Аналітика',
        lead: '«Аналітика» — це місце, де щоденні транзакції перетворюються на розуміння. Замість окремих чисел ви бачите, як ваші гроші поводяться в часі та за категоріями, — тож рішення спираються на факти, а не на здогади.',
        sections: [
          {
            heading: 'Що ви бачите',
            body: '«Аналітика» розкладає ваші гроші за категоріями та групами й показує доходи проти витрат за кілька місяців. З першого погляду видно, куди йдуть найбільші частки грошей і як ваші витрати змінюються від місяця до місяця.',
          },
          {
            heading: 'Як зрозуміти себе',
            body: 'Шукайте найбільші категорії та місяці з незвично високими витратами. Саме ці факти пояснюють, куди насправді йдуть гроші, — часто зовсім не туди, куди ми думаємо. Без осуду, лише чесніше дзеркало.',
          },
          {
            heading: 'Від інсайту до дії',
            body: '«Аналітика» каже, що вже сталося; «Бюджет» допомагає планувати, що має статися далі. Використовуйте їх разом: вивчіть свої реальні витрати тут, а потім задайте ліміти бюджету, реалістичні, бо вони ґрунтуються на ваших власних цифрах.',
          },
        ],
        tips: [
          'Перш ніж складати бюджет, спершу подивіться «Аналітику» — спирайте ліміти на те, що справді витрачаєте, а не на здогад.',
          'Стежте за трендами протягом кількох місяців, а не одного. Один незвичний місяць — ще не закономірність.',
          'Найбільші категорії — там, де невеликі відсотки заощаджень дають найбільший ефект; зосередьте увагу там.',
          'Що послідовніше ви розподіляєте транзакції за категоріями, то надійнішою стає «Аналітика».',
        ],
      },
    },
  },
  cs: {
    tipsLabel: 'Osvědčené postupy',
    backToGuide: 'Všechny příručky',
    readCta: 'Číst',
    hub: {
      eyebrow: 'Průvodce a tipy',
      title: 'Naučte se Finwaze za pár minut',
      lead: 'Začínáte se sledováním peněz? Tyto krátké praktické příručky vás krok za krokem provedou každou částí aplikace — bez znalostí financí. Čtěte v libovolném pořadí, nebo klikněte na „?“ vedle názvu sekce a přejděte rovnou k její příručce.',
      quickStart: {
        title: 'Co dělat hned po registraci',
        steps: [
          'První účet jste si vytvořili už při nastavení — právě tam ve Finwaze leží vaše peníze.',
          'Otevřete „Transakce“ a zapisujte, co utratíte a vyděláte. Stačí minuta denně.',
          'Upravte si kategorie, aby každý výdaj spadl tam, kde to dává smysl vám.',
          'Až budete připraveni, sestavte rozpočet a vytvořte cíl spoření — obojí je volitelné a může počkat.',
        ],
      },
      topicsTitle: 'Průvodce pro každou sekci',
    },
    topics: {
      dashboard: {
        card: {
          title: 'Přehled',
          summary:
            'Vaše finanční domovská obrazovka — peníze za měsíc na první pohled.',
        },
        eyebrow: 'Váš souhrn',
        title: 'Přehled',
        lead: 'Přehled je první, co po otevření Finwaze uvidíte: snímek vašich peněz za tento měsíc — kolik přišlo, kolik odešlo a co zbývá. Shromáždí vše z ostatních sekcí, takže za pár vteřin zjistíte, jak na tom jste.',
        sections: [
          {
            heading: 'Co Přehled ukazuje',
            body: 'Nahoře vidíte souhrnné karty za měsíc: celkové příjmy, celkové výdaje a rozdíl mezi nimi. Níže najdete nedávnou aktivitu a kategorie, na které jste utratili nejvíc. Počítají se zde jen skutečné příjmy a výdaje — peníze přesunuté mezi vlastními účty se vynechávají, takže čísla odrážejí opravdové vydělávání a utrácení.',
          },
          {
            heading: 'Jak číst na první pohled',
            body: 'Jsou-li příjmy vyšší než výdaje, skončili jste období v plusu — ušetřili jste. Jsou-li výdaje vyšší, utratili jste víc, než vydělali; občas to nevadí, ale stojí za sledování. Berte Přehled jako denní či týdenní kontrolu, ne jako něco ke dlouhému studiu.',
          },
          {
            heading: 'Odkud čísla pocházejí',
            body: 'Vše v Přehledu se sestavuje automaticky z transakcí, které zaznamenáte. Není zde co přímo vyplňovat — čím důsledněji transakce zapisujete, tím přesnější a užitečnější tento souhrn je.',
          },
        ],
        tips: [
          'Mrkněte na Přehled každý den, nebo aspoň jednou týdně — je to nejrychlejší způsob, jak mít peníze na očích.',
          'Pokud nějaké číslo vypadá divně, obvykle chybí transakce nebo je ve špatné kategorii. Opravte to v sekci „Transakce“.',
          'Převody mezi vlastními účty se zde záměrně nezapočítávají, takže součty vždy ukazují vaše skutečné příjmy a výdaje.',
        ],
      },
      transactions: {
        card: {
          title: 'Sledování výdajů',
          summary: 'Srdce Finwaze: zapisujte, co přijde a co odejde.',
        },
        eyebrow: 'Základ',
        title: 'Transakce',
        lead: 'Transakce jsou srdcem Finwaze. Nejsnazší je začít prostě zapisovat pohyb svých peněz — všechny ostatní sekce z toho vycházejí. Nepotřebujete nejdřív rozpočet ani žádné nastavení: zaznamenávejte příjmy a výdaje a Finwaze z nich vytvoří jasný obraz, kam vaše peníze plynou.',
        sections: [
          {
            heading: 'Co je transakce?',
            body: 'Transakce je jeden pohyb peněz. Výdaj jsou peníze odcházející z účtu (káva, nájem, potraviny). Příjem jsou peníze přicházející (mzda, vrácení, dárek). Pokaždé, když se peníze pohnou, přidáte jednu transakci — to je celý princip.',
          },
          {
            heading: 'Jak zaznamenat výdaj',
            body: 'Přejděte do „Transakce“ a přidejte novou. Zvolte „výdaj“, zadejte částku, vyberte účet, ze kterého jste platili, a přiřaďte kategorii (například „Potraviny“). Doplňte datum a volitelně poznámku. Uložte — zůstatek účtu se aktualizuje automaticky. Příjem funguje stejně, jen zvolte „příjem“.',
          },
          {
            heading: 'Výdaje v jiné měně',
            body: 'Platili jste v cizí měně? Finwaze uchová obě čísla: částku transakce (co bylo na cenovce, např. 5 EUR) a zaúčtovanou částku (co skutečně odešlo z účtu v jeho měně, např. 130 CZK). Zadáváte jen to, co vidíte — žádný ruční převod není potřeba.',
          },
          {
            heading: 'Převody nejsou výdaje',
            body: 'Přesun peněz mezi vlastními účty — výběr hotovosti, splacení karty, doplnění spoření — je převod, ne výdaj. Zaznamenejte ho jako převod, aby vám nenafoukl výdaje. Váš celkový majetek se nezměnil, jen jeho umístění.',
          },
        ],
        tips: [
          'Zaznamenávejte transakce hned, jak nastanou, nebo jednou na konci dne, aby nic nezapadlo.',
          'Pro stejný druh výdaje používejte pokaždé stejnou kategorii — právě důslednost dělá vaše reporty spolehlivými.',
          'Nezapisujte přesun peněz mezi vlastními účty jako výdaj. To je převod a neměl by se počítat jako výdaj.',
          'Procházejte svůj týden každou neděli. Pět minut stačí, abyste si všimli překvapení a měli vše pod kontrolou.',
        ],
      },
      categories: {
        card: {
          title: 'Skupiny a kategorie',
          summary:
            'Uspořádejte transakce do struktury, která odpovídá vašemu životu.',
        },
        eyebrow: 'Uspořádání',
        title: 'Skupiny a kategorie',
        lead: 'Kategorie jsou štítky, které dáváte každé transakci; skupiny seskupují příbuzné kategorie. Právě dobrá struktura promění prostý seznam transakcí v reporty, ze kterých se opravdu dá poučit — vyplatí se věnovat pár minut tomu, aby seděla na váš reálný život.',
        sections: [
          {
            heading: 'Skupiny versus kategorie',
            body: 'Skupina je široká oblast života — například „Auto“. Kategorie je konkrétní položka uvnitř ní — „Palivo“, „Pojištění“, „Opravy“. Každá transakce dostane právě jednu kategorii a ta patří do skupiny. „Palivo → Auto“ tak ukazuje detail i širší obraz.',
          },
          {
            heading: 'Nastavení kategorií',
            body: 'Finwaze přichází s hotovou sadou skupin a kategorií, takže můžete zapisovat hned. Postupem času je přejmenovávejte, přidávejte chybějící a odebírejte ty, které nepoužíváte, dokud struktura nezrcadlí, jak skutečně žijete a utrácíte. Jediné správné nastavení neexistuje — jen to, které sedí vám.',
          },
          {
            heading: 'Proč na tom záleží',
            body: 'Rozpočty a „Analytika“ jsou tak jasné, jak jasné jsou vaše kategorie. Když stejný druh výdaje vždy spadne do stejné kategorie, reporty zůstávají smysluplné; když je roztříštěný, čísla se rozmažou. Důslednost se zde vyplatí všude jinde.',
          },
        ],
        tips: [
          'Začněte s vestavěnými kategoriemi a upravujte je postupně — nesnažte se navrhnout dokonalou strukturu hned první den.',
          'Méně jasných kategorií je lepší než desítky překrývajících se. Pokud se na nějakou kategorii nikdy nedíváte, sloučte ji s jinou.',
          'Mějte jednu kategorii „Ostatní“ pro vzácné věci — když ale narůstá, je to signál, že je potřeba nová kategorie.',
          'Některé kategorie si Finwaze vyhrazuje pro převody a úpravy zůstatku; ty jsou spravovány za vás a zůstávají skryté.',
        ],
      },
      wallet: {
        card: {
          title: 'Sekce „Peněženka“',
          summary:
            'Vaše účty v jakékoli měně — banka, hotovost, karty a spoření na jednom místě.',
        },
        eyebrow: 'Vaše účty',
        title: 'Peněženka',
        lead: '„Peněženka“ je domovem všech vašich účtů. Účet ve Finwaze odráží reálné místo, kde leží vaše peníze — bankovní účet, hotovost, kartu nebo spořicí pokladničku. Můžete jich vytvořit, kolik chcete, každý ve své měně, a „Peněženka“ vždy ukazuje zůstatek každého z nich.',
        sections: [
          {
            heading: 'Co je „Peněženka“',
            body: '„Peněženka“ vypisuje všechny vaše účty s aktuálním zůstatkem. Každá zaznamenaná transakce patří jednomu účtu a mění jeho zůstatek. Právě udržování účtů v souladu se skutečností dělá každý součet ve Finwaze přesným.',
          },
          {
            heading: 'Tolik účtů a měn, kolik potřebujete',
            body: 'Žádný limit neexistuje. Vytvořte si samostatné účty pro banku, hotovost v peněžence, každou kartu i jakékoli spoření — a každému dejte měnu, kterou skutečně používá (CZK, EUR, USD, UAH a další). Když utrácíte v zahraničí, Finwaze uchová původní cenu i částku zaúčtovanou na účet, takže život s více měnami prostě funguje.',
          },
          {
            heading: 'Přesun peněz mezi účty',
            body: 'Výběr hotovosti, splacení karty či doplnění spoření znamená přesun peněz mezi vašimi účty. To je převod, ne výdaj — váš celkový majetek se nemění. Finwaze drží převody mimo reporty výdajů, takže čísla výdajů zůstávají poctivá.',
          },
        ],
        tips: [
          'Založte si jeden účet pro každé reálné místo, kde držíte peníze. Čím víc „Peněženka“ odráží realitu, tím užitečnější je každý report.',
          'Při přidání účtu nastavte jeho aktuální zůstatek jako výchozí bod, aby čísla od prvního dne odpovídala bance.',
          'Veďte si samostatný hotovostní účet — drobné hotovostní výdaje se ztrácejí nejsnáz.',
          'Zvolte jednu hlavní měnu, ve které denně přemýšlíte; ostatní ať jen odrážejí účty, které je používají.',
          'Účty cílů spoření používejte k oddělení peněz, které nechcete utratit omylem.',
        ],
      },
      budget: {
        card: {
          title: 'Sestavení rozpočtu',
          summary:
            'Nastavte měsíční limity podle kategorií a zastavte přečerpání včas.',
        },
        eyebrow: 'Plánujte dopředu',
        title: 'Rozpočet',
        lead: 'Rozpočet je prostě plán, kolik hodláte v každé kategorii během měsíce utratit. Nejde o omezování sebe sama — jde o to rozhodnout, kam peníze půjdou, ještě než zmizí, aby konec měsíce nepřinášel překvapení.',
        sections: [
          {
            heading: 'Co je rozpočet',
            body: 'Rozpočet přiřadí kategorii měsíční limit výdajů — například 4 000 CZK na „Potraviny“ nebo 1 000 CZK na „Restaurace“. Jak zaznamenáváte výdaje, Finwaze je porovnává s těmito limity, takže vždy víte, kolik ještě zbývá.',
          },
          {
            heading: 'První rozpočet',
            body: 'Otevřete sekci „Rozpočet“, zvolte kategorii a zadejte částku, kterou na ni chcete tento měsíc vynaložit. Začněte jen dvěma třemi kategoriemi, na kterých vám nejvíc záleží — další lze vždy přidat později. Není nutné rozpočtovat vše od prvního dne.',
          },
          {
            heading: 'Sledování postupu',
            body: 'Každý rozpočet ukazuje ukazatel postupu, který se s výdaji plní. Zelená znamená, že jste v mezích; jak se blížíte k limitu, objeví se varování, takže výdaje upravíte včas, místo abyste to zjistili až poté. Rozpočty se na začátku každého měsíce obnoví.',
          },
        ],
        tips: [
          'Nastavujte limity podle reality, ne podle přání. Nejdřív měsíc sledujte, podívejte se do „Analytiky“ a pak nastavte limity blízké skutečným výdajům.',
          'Začněte s několika kategoriemi. Rozpočet, který dodržíte, je lepší než dokonalý, který za týden opustíte.',
          'Ponechte si malou rezervní kategorii na nečekané — vždycky se něco najde.',
          'Jednoduchý začátek je pravidlo 50/30/20: zhruba 50 % příjmu na potřeby, 30 % na přání, 20 % na spoření a dluhy.',
          'Na začátku každého měsíce rozpočet projděte a limity upravte podle změn ve svém životě.',
        ],
      },
      goals: {
        card: {
          title: 'Cíle spoření',
          summary: 'Spořte na něco konkrétního a sledujte, jak postup roste.',
        },
        eyebrow: 'Spořte s cílem',
        title: 'Cíle spoření',
        lead: 'Cíl spoření promění mlhavé přání („měl bych víc spořit“) v konkrétní cíl, kterého lze opravdu dosáhnout — dovolená, rezerva, nový notebook. Finwaze dá každému cíli vlastní účet, takže peníze zůstávají oddělené a váš postup je vždy vidět.',
        sections: [
          {
            heading: 'Co je cíl spoření',
            body: 'Cíl je částka, kterou si chcete odložit, řekněme 30 000 CZK na cestu. Stojí za ním vyhrazený spořicí účet, takže odložené peníze zůstávají stranou od běžných výdajů a nevyčerpají se náhodou.',
          },
          {
            heading: 'Vytvoření cíle',
            body: 'Otevřete sekci „Cíle“ a vytvořte nový: dejte mu název, cílovou částku a měnu. Finwaze pro něj založí spořicí účet. Od té chvíle máte jasnou cílovou metu, k níž směřovat.',
          },
          {
            heading: 'Doplňování a sledování',
            body: 'Chcete-li dát peníze na cíl, převeďte je z běžného účtu na spořicí účet cíle. Převod přesouvá peníze mezi vašimi účty, aniž by se počítal jako výdaj. Ukazatel postupu cíle roste s každým příspěvkem a ukazuje, jak blízko jste k metě.',
          },
        ],
        tips: [
          'Nejdřív si vytvořte rezervu — na tři až šest měsíců výdajů — než začnete spořit na nadstandard. Je to cíl, který chrání všechny ostatní.',
          'Plaťte nejdřív sobě: peníze na cíl převeďte hned po výplatě, ještě než utratíte cokoli jiného.',
          'Dejte každému cíli jeden jasný účel. Oddělené cíle motivují snáz než jedna velká mlhavá hromada.',
          'I malé pravidelné příspěvky se sčítají rychleji, než čekáte. Důslednost vítězí nad velikostí.',
        ],
      },
      analytics: {
        card: {
          title: 'Analytika',
          summary: 'Uvidíte trendy a vzorce za vašimi výdaji.',
        },
        eyebrow: 'Vhledy',
        title: 'Analytika',
        lead: '„Analytika“ je místo, kde se vaše každodenní transakce mění ve vhled. Místo jednotlivých čísel vidíte, jak se vaše peníze chovají v čase a napříč kategoriemi — takže se rozhodujete podle faktů, ne podle dohadů.',
        sections: [
          {
            heading: 'Co můžete vidět',
            body: '„Analytika“ rozkládá vaše peníze podle kategorií a skupin a ukazuje příjmy proti výdajům za několik měsíců. Na první pohled poznáte, kam plynou největší části peněz a jak se vaše výdaje mění měsíc od měsíce.',
          },
          {
            heading: 'Jak porozumět sám sobě',
            body: 'Hledejte své největší kategorie a měsíce s neobvykle vysokými výdaji. Právě tato fakta vysvětlují, kam peníze skutečně jdou — často docela jinam, než předpokládáme. Bez soudů, jen jasnější zrcadlo.',
          },
          {
            heading: 'Od vhledu k činu',
            body: '„Analytika“ říká, co se už stalo; „Rozpočet“ pomáhá plánovat, co se má stát dál. Používejte je společně: prostudujte si zde své skutečné výdaje a pak nastavte limity rozpočtu, které jsou reálné, protože vycházejí z vašich vlastních čísel.',
          },
        ],
        tips: [
          'Než sestavíte jakýkoli rozpočet, podívejte se nejdřív do „Analytiky“ — limity opřete o to, co skutečně utrácíte, ne o dohad.',
          'Sledujte trendy napříč několika měsíci, ne jediným. Jeden neobvyklý měsíc ještě není vzorec.',
          'Vaše největší kategorie jsou tam, kde malé procentní úspory přinesou největší rozdíl — tam zaměřte pozornost.',
          'Čím důsledněji transakce zařazujete do kategorií, tím spolehlivější „Analytika“ je.',
        ],
      },
    },
  },
};
