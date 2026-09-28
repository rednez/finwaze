import Foundation

/// Row of `get_monthly_savings_overview`.
nonisolated struct MonthlySavingsDto: Decodable, Sendable {
    /// `DATE`: the month's first day, `YYYY-MM-DD`.
    let month: String
    let currentYearAmount: Decimal?
    let previousYearAmount: Decimal?

    enum CodingKeys: String, CodingKey {
        case month
        case currentYearAmount = "current_year_amount"
        case previousYearAmount = "previous_year_amount"
    }
}
