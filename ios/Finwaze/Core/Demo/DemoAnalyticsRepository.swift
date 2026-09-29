import Foundation

/// Demo-mode Analytics (`AUTH-10`): figures worked out from the same demo transactions the Transactions list, the
/// Wallet and the Dashboard show, so they agree — unlike the web demo's fixed numbers. The budget comes from
/// `DemoBudgetRepository`. Nothing here writes.
nonisolated struct DemoAnalyticsRepository: AnalyticsRepository {
    var calendar: Calendar = .current
    var now: @Sendable () -> Date = { .now }

    func summary(_ query: AnalyticsQuery) async throws -> AnalyticsSummary {
        let current = records(in: query.month, query)
        let previous = records(in: query.month.adding(months: -1), query)
        let incomes = current.filter { $0.isIncome(by: \.chargedAmount) }
        let expenses = current.filter { $0.isExpense(by: \.chargedAmount) }
        return AnalyticsSummary(
            monthlyIncome: incomes.income(\.chargedAmount),
            previousMonthlyIncome: previous.income(\.chargedAmount),
            monthlyExpense: expenses.expense(\.chargedAmount),
            previousMonthlyExpense: previous.expense(\.chargedAmount),
            totalBalance: balance(atEndOf: query.month, query),
            previousTotalBalance: balance(atEndOf: query.month.adding(months: -1), query),
            incomeTransactionCount: incomes.count,
            expenseTransactionCount: expenses.count,
            incomeGroupsCount: Set(incomes.map(\.group.id)).count,
            expenseGroupsCount: Set(expenses.map(\.group.id)).count
        )
    }

    /// Every day of the month; the balance at a day's end is the month's closing balance less what came after the
    /// day.
    func dailyOverview(_ query: AnalyticsQuery) async throws -> [DailyOverviewPoint] {
        guard
            let start = query.month.start(in: calendar),
            let days = calendar.range(of: .day, in: .month, for: start)
        else { return [] }
        let records = records(in: query.month, query)
        let closing = balance(atEndOf: query.month, query)
        return days.compactMap { dayOfMonth in
            guard
                let day = calendar.date(byAdding: .day, value: dayOfMonth - 1, to: start),
                let next = calendar.date(byAdding: .day, value: 1, to: day)
            else { return nil }
            let onDay = records.filter { $0.transactedAt >= day && $0.transactedAt < next }
            let later = records.filter { $0.transactedAt >= next }
            return DailyOverviewPoint(
                day: day,
                dayOfMonth: dayOfMonth,
                income: onDay.income(\.chargedAmount),
                expense: onDay.expense(\.chargedAmount),
                balance: closing - Self.total(later)
            )
        }
    }

    /// Like the server: groups with an income or an expense, largest expense first, then by name.
    func amountsByGroup(_ query: AnalyticsQuery) async throws -> [GroupAmounts] {
        let counted = records(in: query.month, query).filter { $0.isCounted && $0.chargedAmount != 0 }
        return Dictionary(grouping: counted, by: \.group.id).values
            .compactMap { records -> GroupAmounts? in
                guard let group = records.first?.group else { return nil }
                return GroupAmounts(
                    id: group.id,
                    name: group.name,
                    income: records.income(\.chargedAmount),
                    expense: records.expense(\.chargedAmount)
                )
            }
            .sorted { ($1.expense, $0.name) < ($0.expense, $1.name) }
    }

    /// The demo plan of every month against the expenses charged to accounts in the currency (`Q-03`).
    func yearlyBudgetsVsExpenses(year: Int, currencyCode: String) async throws -> [MonthlyBudgetExpense] {
        let budget = DemoBudgetRepository(calendar: calendar, now: now)
        var months: [MonthlyBudgetExpense] = []
        for number in 1...12 {
            let month = YearMonth(year: year, month: number)
            let totals = try await budget.totals(BudgetQuery(month: month, currencyCode: currencyCode, groupID: nil))
            let query = AnalyticsQuery(month: month, currencyCode: currencyCode, accountIDs: [])
            let expense = records(in: month, query).expense(\.chargedAmount)
            months.append(MonthlyBudgetExpense(month: month, budget: totals.planned, expense: expense))
        }
        return months
    }

    /// The month's records charged to the query's accounts in its currency, transfers included.
    private func records(in month: YearMonth, _ query: AnalyticsQuery) -> [Transaction] {
        DemoData.transactions(in: month, now: now(), calendar: calendar).filter {
            $0.chargedCurrencyCode == query.currencyCode
                && (query.accountIDs.isEmpty || query.accountIDs.contains($0.accountID))
        }
    }

    /// Today's balance less every record after the month (`GEN-03`); a later month has today's balance.
    private func balance(atEndOf month: YearMonth, _ query: AnalyticsQuery) -> Decimal {
        let now = now()
        let thisMonth = YearMonth(now, in: calendar)
        var balance = currentBalance(query, now: now)
        var later = month.adding(months: 1)
        while (later.year, later.month) <= (thisMonth.year, thisMonth.month) {
            balance -= Self.total(records(in: later, query))
            later = later.adding(months: 1)
        }
        return balance
    }

    /// The query's accounts' balances today; with every account, goal accounts too, like the Dashboard (`DASH-02`).
    private func currentBalance(_ query: AnalyticsQuery, now: Date) -> Decimal {
        let accounts = DemoData.walletAccounts
            .filter { $0.currencyCode == query.currencyCode && (query.accountIDs.isEmpty || query.accountIDs.contains($0.id)) }
            .reduce(Decimal(0)) { $0 + $1.balance }
        guard query.accountIDs.isEmpty else { return accounts }
        let goals = DemoData.savingsGoals(now: now, calendar: calendar)
            .filter { $0.currencyCode == query.currencyCode }
            .reduce(Decimal(0)) { $0 + $1.accumulatedAmount }
        return accounts + goals
    }

    private static func total(_ transactions: [Transaction]) -> Decimal {
        transactions.reduce(0) { $0 + $1.chargedAmount }
    }
}
