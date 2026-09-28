import Foundation

/// The month's budget, by group or within one group (`BUD-01…17`). Amounts are positive.
protocol BudgetRepository: Sendable {
    /// Every group — or the group's categories — with a plan or spending, planned ones first by plan (`BUD-05`,
    /// `BUD-12`, `BUD-17`).
    func budgets(_ query: BudgetQuery) async throws -> [BudgetItem]
    /// Planned and spent in total (`BUD-13`, `BUD-17`).
    func totals(_ query: BudgetQuery) async throws -> BudgetTotals
    /// The month's expenses by group — or by the group's categories — largest first, with the month before
    /// (`BUD-14`, `BUD-17`).
    func expenses(_ query: BudgetQuery) async throws -> [MonthlyExpense]
}
