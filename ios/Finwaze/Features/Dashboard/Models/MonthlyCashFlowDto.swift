import Foundation

/// Row of `get_monthly_charged_cash_flow`; only months with transactions come back.
nonisolated struct MonthlyCashFlowDto: Decodable, Sendable {
    /// `TIMESTAMPTZ` of the month's start in the server's time zone (UTC): `2026-09-01T00:00:00+00:00`.
    let month: String
    let totalIncome: Decimal?
    /// Negative.
    let totalExpense: Decimal?

    enum CodingKeys: String, CodingKey {
        case month
        case totalIncome = "total_income"
        case totalExpense = "total_expense"
    }
}
