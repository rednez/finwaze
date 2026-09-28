import Foundation

/// Row of `get_monthly_budgets_detailed` and `generate_monthly_budgets_from_previous`, which return the same columns.
/// Amounts come positive.
nonisolated struct MonthlyBudgetDetailedDto: Decodable, Sendable {
    let categoryID: Int64
    let categoryName: String
    let groupID: Int64
    let groupName: String
    let plannedAmount: Decimal?
    let previousPlannedAmount: Decimal?
    let spentAmount: Decimal?
    let previousSpentAmount: Decimal?

    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case categoryName = "category_name"
        case groupID = "group_id"
        case groupName = "group_name"
        case plannedAmount = "planned_amount"
        case previousPlannedAmount = "previous_planned_amount"
        case spentAmount = "spent_amount"
        case previousSpentAmount = "previous_spent_amount"
    }
}
