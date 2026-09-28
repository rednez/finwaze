import Foundation

/// Row of `get_yearly_budgets_vs_expenses`: one for every month of the year.
nonisolated struct MonthlyBudgetExpenseDto: Decodable, Sendable {
    /// `DATE`, the month's first day: `2026-09-01`.
    let month: String
    /// Positive.
    let budgetAmount: Decimal?
    /// Positive.
    let expenseAmount: Decimal?

    enum CodingKeys: String, CodingKey {
        case month
        case budgetAmount = "budget_amount"
        case expenseAmount = "expense_amount"
    }
}
