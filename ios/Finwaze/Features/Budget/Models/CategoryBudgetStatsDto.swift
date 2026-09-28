import Foundation

/// Row of `get_category_budget_stats`; amounts come positive.
nonisolated struct CategoryBudgetStatsDto: Decodable, Sendable {
    let previousPlannedAmount: Decimal?
    let spentAmount: Decimal?
    let previousSpentAmount: Decimal?

    enum CodingKeys: String, CodingKey {
        case previousPlannedAmount = "previous_planned_amount"
        case spentAmount = "spent_amount"
        case previousSpentAmount = "previous_spent_amount"
    }
}
