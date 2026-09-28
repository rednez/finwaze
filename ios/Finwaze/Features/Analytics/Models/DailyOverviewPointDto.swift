import Foundation

/// Row of `get_daily_financial_overview_for_month`: one for every day of the month, zeros included.
nonisolated struct DailyOverviewPointDto: Decodable, Sendable {
    /// `DATE`: `2026-09-30`.
    let day: String
    /// Positive.
    let dailyIncome: Decimal?
    /// Positive.
    let dailyExpense: Decimal?
    let runningBalance: Decimal?

    enum CodingKeys: String, CodingKey {
        case day
        case dailyIncome = "daily_income"
        case dailyExpense = "daily_expense"
        case runningBalance = "running_balance"
    }
}
