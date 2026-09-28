import Foundation

/// A group's or category's expenses in a month and the month before, for "Most expenses" (`BUD-14`).
nonisolated struct MonthlyExpense: Identifiable, Equatable, Sendable {
    let id: Int64
    let name: String
    let amount: Decimal
    let previousAmount: Decimal

    /// Growth of spending is bad (`BUD-14`).
    var trend: TrendChange {
        TrendChange(current: amount, previous: previousAmount, growthIsGood: false)
    }
}
