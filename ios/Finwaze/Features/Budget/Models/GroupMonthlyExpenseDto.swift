import Foundation

/// Row of `get_monthly_expenses_by_groups`; amounts come positive.
nonisolated struct GroupMonthlyExpenseDto: Decodable, Sendable {
    let groupID: Int64
    let groupName: String
    let selectedMonthAmount: Decimal?
    let previousMonthAmount: Decimal?

    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case groupName = "group_name"
        case selectedMonthAmount = "selected_month_amount"
        case previousMonthAmount = "previous_month_amount"
    }
}
