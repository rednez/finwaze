import Foundation

/// Row of `get_monthly_transaction_amounts_by_group`.
nonisolated struct GroupAmountsDto: Decodable, Sendable {
    let groupID: Int64
    let groupName: String
    let totalIncome: Decimal?
    /// Negative.
    let totalExpense: Decimal?

    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case groupName = "group_name"
        case totalIncome = "total_income"
        case totalExpense = "total_expense"
    }
}
