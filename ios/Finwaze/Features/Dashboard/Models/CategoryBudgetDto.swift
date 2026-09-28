import Foundation

/// Row of `get_current_month_budgets_by_category`. The server groups by category name, so categories with the same
/// name in different groups come as one row (see `ios/docs/TECH_DEBT.md`).
nonisolated struct CategoryBudgetDto: Decodable, Sendable {
    let categoryName: String
    let totalBudget: Decimal

    enum CodingKeys: String, CodingKey {
        case categoryName = "category_name"
        case totalBudget = "total_budget"
    }
}
