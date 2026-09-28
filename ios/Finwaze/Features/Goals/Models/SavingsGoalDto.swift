import Foundation

/// Row of `get_savings_goals`.
nonisolated struct SavingsGoalDto: Decodable, Sendable {
    let id: Int64
    let name: String
    let currencyCode: String
    /// `DATE`: `YYYY-MM-DD`.
    let targetDate: String
    let status: SavingsGoalStatus
    let targetAmount: Decimal
    let accumulatedAmount: Decimal
    let hasTransfers: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, status
        case currencyCode = "currency_code"
        case targetDate = "target_date"
        case targetAmount = "target_amount"
        case accumulatedAmount = "accumulated_amount"
        case hasTransfers = "has_transfers"
    }
}
