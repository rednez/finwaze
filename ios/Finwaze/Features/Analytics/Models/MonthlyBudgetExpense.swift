import Foundation

/// A month of "Budgets vs Expenses" (`ANL-04`): the plan in the budget's currency against the expenses charged to
/// accounts in it (`Q-03`).
nonisolated struct MonthlyBudgetExpense: Identifiable, Equatable, Sendable {
    let month: YearMonth
    /// Positive.
    let budget: Decimal
    /// Positive.
    let expense: Decimal

    var id: YearMonth { month }
}
