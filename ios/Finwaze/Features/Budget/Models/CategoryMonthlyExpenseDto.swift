import Foundation

/// Row of `get_monthly_expenses_by_categories`; amounts come positive.
nonisolated struct CategoryMonthlyExpenseDto: Decodable, Sendable {
    let categoryID: Int64
    let categoryName: String
    let selectedMonthAmount: Decimal?
    let previousMonthAmount: Decimal?

    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case categoryName = "category_name"
        case selectedMonthAmount = "selected_month_amount"
        case previousMonthAmount = "previous_month_amount"
    }
}
