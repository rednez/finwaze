import Foundation

/// Row of `get_daily_transactions_cash_flow_for_month`: one for every day of the month, zeros included.
nonisolated struct DailyCashFlowDto: Decodable, Sendable {
    /// `DATE`: `2026-09-30`.
    let day: String
    let totalIncome: Decimal?
    /// Negative.
    let totalExpense: Decimal?

    enum CodingKeys: String, CodingKey {
        case day
        case totalIncome = "total_income"
        case totalExpense = "total_expense"
    }
}
