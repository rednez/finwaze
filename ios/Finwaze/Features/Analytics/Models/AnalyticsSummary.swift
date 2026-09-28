import Foundation

/// The three summary cards' figures for a month and the month before (`ANL-02`). Incomes and expenses leave out
/// transfers and corrections (`GEN-02`); the balance counts every record up to the month's end (`GEN-03`).
nonisolated struct AnalyticsSummary: Equatable, Sendable {
    let monthlyIncome: Decimal
    let previousMonthlyIncome: Decimal
    /// As a positive amount.
    let monthlyExpense: Decimal
    let previousMonthlyExpense: Decimal
    /// At the end of the month.
    let totalBalance: Decimal
    /// At the end of the month before.
    let previousTotalBalance: Decimal
    let incomeTransactionCount: Int
    let expenseTransactionCount: Int
    let incomeGroupsCount: Int
    let expenseGroupsCount: Int

    static let zero = AnalyticsSummary(
        monthlyIncome: 0,
        previousMonthlyIncome: 0,
        monthlyExpense: 0,
        previousMonthlyExpense: 0,
        totalBalance: 0,
        previousTotalBalance: 0,
        incomeTransactionCount: 0,
        expenseTransactionCount: 0,
        incomeGroupsCount: 0,
        expenseGroupsCount: 0
    )
}
