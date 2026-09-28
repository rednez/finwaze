import Foundation

protocol DashboardRepository: Sendable {
    /// Balance, this month's income and expenses and last month's for comparison, in one currency (`DASH-02`).
    func totals(currencyCode: String) async throws -> DashboardTotals
    /// Incomes and expenses charged to accounts in the currency over the last `months` months, oldest first, with
    /// every month present (`DASH-04`).
    func monthlyCashFlow(currencyCode: String, months: Int) async throws -> [MonthlyCashFlow]
    /// This month's planned budget per category in the currency (`DASH-05`).
    func currentMonthBudgets(currencyCode: String) async throws -> [CategoryBudget]
    /// The newest incomes, expenses and transfers in every currency, without balance corrections (`DASH-06`, `GEN-04`).
    func recentTransactions(limit: Int) async throws -> [Transaction]
    /// The newest savings goals, by creation (`DASH-07`).
    func recentGoals(limit: Int) async throws -> [SavingsGoal]
}
