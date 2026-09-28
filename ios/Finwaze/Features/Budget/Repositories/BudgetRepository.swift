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

    /// The month's plan in the currency: categories with a planned amount, largest first, with their reference
    /// figures (`BUD-20`, `BUD-22`).
    func plan(month: YearMonth, currencyCode: String) async throws -> [BudgetPlanLine]
    /// A proposed plan — last month's budget, else last month's spending, else this month's — for each category
    /// with any of them (`BUD-21`). Nothing is saved.
    func generatedPlan(month: YearMonth, currencyCode: String) async throws -> [BudgetPlanLine]
    /// A category's reference figures, for one added to the plan by hand (`BUD-24`).
    func categoryStats(month: YearMonth, currencyCode: String, categoryID: Int64) async throws -> BudgetPlanStats
    /// Replaces the month's plan in the currency with `amounts` (category id → amount): new categories are added,
    /// changed ones updated, missing ones deleted (`BUD-26`).
    func savePlan(month: YearMonth, currencyCode: String, amounts: [Int64: Decimal]) async throws
}
