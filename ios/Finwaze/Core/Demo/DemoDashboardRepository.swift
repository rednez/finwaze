import Foundation

/// Demo-mode Dashboard (`AUTH-10`): figures worked out from the same demo transactions the Transactions list shows,
/// so the two agree — unlike the web demo's fixed numbers. Budgets and goals come from `DemoData`. Nothing here
/// writes.
nonisolated struct DemoDashboardRepository: DashboardRepository {
    var calendar: Calendar = .current
    var now: @Sendable () -> Date = { .now }

    func totals(currencyCode: String) async throws -> DashboardTotals {
        let now = now()
        let current = transactions(inMonthOf: now, currencyCode: currencyCode)
        let previous = transactions(inMonthOf: previousMonth(of: now), currencyCode: currencyCode)

        // Goal accounts count towards the balance too (`DASH-02`).
        let accounts: Decimal = DemoData.walletAccounts
            .filter { $0.currencyCode == currencyCode }
            .reduce(0) { $0 + $1.balance }
        let goals: Decimal = DemoData.savingsGoals(now: now, calendar: calendar)
            .filter { $0.currencyCode == currencyCode }
            .reduce(0) { $0 + $1.accumulatedAmount }
        let balance = accounts + goals
        // Last month's closing balance: this month's records, transfers included, taken back (`GEN-03`).
        let thisMonth = current.reduce(Decimal(0)) { $0 + $1.chargedAmount }

        return DashboardTotals(
            totalBalance: balance,
            monthlyIncome: current.income(\.chargedAmount),
            monthlyExpense: current.expense(\.chargedAmount),
            previousTotalBalance: balance - thisMonth,
            previousMonthlyIncome: previous.income(\.chargedAmount),
            previousMonthlyExpense: previous.expense(\.chargedAmount)
        )
    }

    func monthlyCashFlow(currencyCode: String, months: Int) async throws -> [MonthlyCashFlow] {
        DashboardMapper.lastMonths(months, now: now()).compactMap { month in
            guard let start = month.start(in: calendar) else { return nil }
            let transactions = transactions(inMonthOf: start, currencyCode: currencyCode)
            return MonthlyCashFlow(month: start, income: transactions.income(\.chargedAmount), expense: transactions.expense(\.chargedAmount))
        }
    }

    func currentMonthBudgets(currencyCode: String) async throws -> [CategoryBudget] {
        currencyCode == DemoData.budgetCurrencyCode ? DemoData.budgets : []
    }

    /// This month's newest, topped up from last month early in the month.
    func recentTransactions(limit: Int) async throws -> [Transaction] {
        let now = now()
        let recent = DemoData.transactions(inMonthOf: now, now: now, calendar: calendar)
            + DemoData.transactions(inMonthOf: previousMonth(of: now), now: now, calendar: calendar)
        return Array(recent.prefix(limit))
    }

    func recentGoals(limit: Int) async throws -> [SavingsGoal] {
        Array(DemoData.savingsGoals(now: now(), calendar: calendar).prefix(limit))
    }

    /// The month's records charged in the currency, transfers included.
    private func transactions(inMonthOf month: Date, currencyCode: String) -> [Transaction] {
        DemoData.transactions(inMonthOf: month, now: now(), calendar: calendar)
            .filter { $0.chargedCurrencyCode == currencyCode }
    }

    private func previousMonth(of date: Date) -> Date {
        calendar.date(byAdding: .month, value: -1, to: date) ?? date
    }
}
