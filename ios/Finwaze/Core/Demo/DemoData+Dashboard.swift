import Foundation

/// Demo budgets and savings goals, the same as the web client's (`get_current_month_budgets_by_category` and
/// `SAVINGS_GOALS` in `src/app/core/services/demo-mode/demo-data.ts`).
nonisolated extension DemoData {
    /// This month's planned budget, in USD — the currency of the demo transactions.
    static let budgetCurrencyCode = "USD"

    static let budgets = [
        CategoryBudget(name: "Groceries", amount: 250),
        CategoryBudget(name: "Rent", amount: 1200),
        CategoryBudget(name: "Transport", amount: 100),
    ]

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
