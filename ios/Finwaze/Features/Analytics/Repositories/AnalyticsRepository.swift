import Foundation

/// Analytics' figures (`ANL-01…06`): amounts charged to accounts in the query's currency, in the local time of each
/// record (`ANL-06`, `GEN-12`). The budget by group comes from `BudgetRepository.budgets`.
protocol AnalyticsRepository: Sendable {
    /// The month's and the month before's incomes, expenses and balances, with counts (`ANL-02`).
    func summary(_ query: AnalyticsQuery) async throws -> AnalyticsSummary
    /// Every day of the month: incomes, expenses and the balance at the day's end (`ANL-03`).
    func dailyOverview(_ query: AnalyticsQuery) async throws -> [DailyOverviewPoint]
    /// The month's incomes and expenses by group, without system groups (`ANL-05`, `GEN-05`).
    func amountsByGroup(_ query: AnalyticsQuery) async throws -> [GroupAmounts]
    /// Every month of the year: the budget and the expenses charged to accounts in the currency (`ANL-04`).
    func yearlyBudgetsVsExpenses(year: Int, currencyCode: String) async throws -> [MonthlyBudgetExpense]
}
