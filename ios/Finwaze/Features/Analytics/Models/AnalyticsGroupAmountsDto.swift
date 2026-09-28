import Foundation

/// Row of `get_analytics_amounts_by_groups`: amounts charged in the currency, both positive, without system groups.
nonisolated struct AnalyticsGroupAmountsDto: Decodable, Sendable {
    let groupID: Int64
    let groupName: String
    let incomeAmount: Decimal?
    let expenseAmount: Decimal?

    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case groupName = "group_name"
        case incomeAmount = "income_amount"
        case expenseAmount = "expense_amount"
    }
}
