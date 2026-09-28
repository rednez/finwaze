import Foundation

/// The three summary cards in one currency, with last month's values for the change badges (`DASH-02`, `DASH-03`).
/// Only incomes and expenses count towards income and expenses (`GEN-02`); the balance is every record of every
/// account in the currency, goal accounts included (`GEN-03`).
nonisolated struct DashboardTotals: Equatable, Sendable {
    /// All time.
    let totalBalance: Decimal
    /// This month.
    let monthlyIncome: Decimal
    /// This month, as a positive amount.
    let monthlyExpense: Decimal
    /// At the end of last month.
    let previousTotalBalance: Decimal
    let previousMonthlyIncome: Decimal
    /// Last month, as a positive amount.
    let previousMonthlyExpense: Decimal

    static let zero = DashboardTotals(
        totalBalance: 0,
        monthlyIncome: 0,
        monthlyExpense: 0,
        previousTotalBalance: 0,
        previousMonthlyIncome: 0,
        previousMonthlyExpense: 0
    )
}
