import Foundation

/// Row of `get_monthly_budgets_by_groups`. `spent_amount` comes negative (a sum of expenses).
nonisolated struct GroupMonthlyBudgetDto: Decodable, Sendable {
    let groupID: Int64
    let groupName: String
    let plannedAmount: Decimal?
    let spentAmount: Decimal?
    let categoriesCount: Int?
    let isUnplanned: Bool

    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case groupName = "group_name"
        case plannedAmount = "planned_amount"
        case spentAmount = "spent_amount"
        case categoriesCount = "categories_count"
        case isUnplanned = "is_unplanned"
    }
}
