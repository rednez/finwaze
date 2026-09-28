import Foundation

/// Demo budgets and savings goals. Goals are the web client's (`SAVINGS_GOALS` in
/// `src/app/core/services/demo-mode/demo-data.ts`); the budget follows the web's too, but per demo category — the web's
/// "Transport 100" is split between Taxi and Public Transport — so Budget can set it against the demo expenses.
nonisolated extension DemoData {
    /// The planned budget, in USD — the currency of the demo transactions.
    static let budgetCurrencyCode = "USD"

    /// Planned amount per category id; the same plan every month, so last month has one too (`BUD-06`).
    static let plannedBudgets: [(categoryID: Int64, amount: Decimal)] = [
        (categoryID: 1, amount: 250), // Groceries
        (categoryID: 7, amount: 1200), // Rent
        (categoryID: 3, amount: 60), // Taxi
        (categoryID: 4, amount: 40), // Public Transport
    ]

    /// This month's plan by category, for the Dashboard (`DASH-05`).
    static let budgets: [CategoryBudget] = plannedBudgets.compactMap { budget in
        categories.first { $0.id == budget.categoryID }.map { CategoryBudget(name: $0.name, amount: budget.amount) }
    }

    /// Newest first; target dates are relative to `now`, so the goals never expire.
    static func savingsGoals(now: Date = .now, calendar: Calendar = .current) -> [SavingsGoal] {
        let today = calendar.startOfDay(for: now)
        func inMonths(_ months: Int) -> Date {
            calendar.date(byAdding: .month, value: months, to: today) ?? today
        }
        return [
            SavingsGoal(
                id: 101,
                name: "Emergency Fund",
                currencyCode: "USD",
                targetDate: inMonths(8),
                status: .inProgress,
                targetAmount: 10000,
                accumulatedAmount: 5800,
                hasTransfers: true
            ),
            SavingsGoal(
                id: 102,
                name: "Vacation",
                currencyCode: "EUR",
                targetDate: inMonths(4),
                status: .inProgress,
                targetAmount: 2000,
                accumulatedAmount: 850,
                hasTransfers: true
            ),
        ]
    }
}
