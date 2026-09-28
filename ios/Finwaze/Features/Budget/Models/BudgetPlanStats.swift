import Foundation

/// A category's reference figures in the plan editor (`BUD-22`, `BUD-24`): last month's plan and spending, and this
/// month's spending so far. Amounts are positive, in the plan's currency.
nonisolated struct BudgetPlanStats: Equatable, Sendable {
    let previousPlanned: Decimal
    let spent: Decimal
    let previousSpent: Decimal

    static let zero = BudgetPlanStats(previousPlanned: 0, spent: 0, previousSpent: 0)
}
