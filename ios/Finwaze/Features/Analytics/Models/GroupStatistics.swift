import Foundation

/// "Statistics" (`ANL-05`): the month's incomes and expenses by group and the budget by group, loaded together.
nonisolated struct GroupStatistics: Equatable, Sendable {
    /// Charged to the selected accounts.
    let amounts: [GroupAmounts]
    /// The budget has no accounts, so the account filter does not apply.
    let budgets: [BudgetItem]
}
