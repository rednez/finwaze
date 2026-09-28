import Foundation

/// Net deposits into the goals' accounts in one currency during a month of the year and the same month a year
/// earlier (`GOAL-16`). Withdrawals count against deposits, so an amount may be negative.
nonisolated struct MonthlySavings: Identifiable, Equatable, Sendable {
    let month: YearMonth
    let currentYear: Decimal
    let previousYear: Decimal

    var id: YearMonth { month }
}
