import Foundation

/// Row of `get_dashboard_totals`; expenses come negative, and any column may be `null`.
nonisolated struct DashboardTotalsDto: Decodable, Sendable {
    let totalBalance: Decimal?
    let monthlyIncome: Decimal?
    let monthlyExpense: Decimal?
    let previousTotalBalance: Decimal?
    let previousMonthlyIncome: Decimal?
    let previousMonthlyExpense: Decimal?

    enum CodingKeys: String, CodingKey {
        case totalBalance = "total_balance"
        case monthlyIncome = "monthly_income"
        case monthlyExpense = "monthly_expense"
        case previousTotalBalance = "previous_total_balance"
        case previousMonthlyIncome = "previous_monthly_income"
        case previousMonthlyExpense = "previous_monthly_expense"
    }
}
