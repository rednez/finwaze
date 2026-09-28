import Foundation

/// The single row of `get_analytics_financial_summary`. Expenses are already positive.
nonisolated struct AnalyticsSummaryDto: Decodable, Sendable {
    let monthlyIncome: Decimal?
    let previousMonthlyIncome: Decimal?
    let monthlyExpense: Decimal?
    let previousMonthlyExpense: Decimal?
    let totalBalance: Decimal?
    let previousTotalBalance: Decimal?
    let incomeTransactionCount: Int?
    let expenseTransactionCount: Int?
    let incomeGroupsCount: Int?
    let expenseGroupsCount: Int?

    enum CodingKeys: String, CodingKey {
        case monthlyIncome = "monthly_income"
        case previousMonthlyIncome = "previous_monthly_income"
        case monthlyExpense = "monthly_expense"
        case previousMonthlyExpense = "previous_monthly_expense"
        case totalBalance = "total_balance"
        case previousTotalBalance = "previous_total_balance"
        case incomeTransactionCount = "income_transaction_count"
        case expenseTransactionCount = "expense_transaction_count"
        case incomeGroupsCount = "income_groups_count"
        case expenseGroupsCount = "expense_groups_count"
    }
}
