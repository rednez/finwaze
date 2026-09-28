import Foundation

/// Row of `get_monthly_budgets_by_categories`. `spent_amount` comes negative (a sum of expenses).
nonisolated struct CategoryMonthlyBudgetDto: Decodable, Sendable {
    let categoryID: Int64
    let categoryName: String
    let plannedAmount: Decimal?
    let spentAmount: Decimal?
    let isUnplanned: Bool

    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case categoryName = "category_name"
        case plannedAmount = "planned_amount"
        case spentAmount = "spent_amount"
        case isUnplanned = "is_unplanned"
    }
}
