import Foundation

/// "$150.00 more than last month" under a summary card (`ANL-02`), like the web's `FinancialSummaryCard`.
nonisolated struct SummaryComparison: Equatable, Sendable {
    enum Direction: Equatable, Sendable {
        case more, less, same
    }

    /// The size of the difference, never negative.
    let difference: Decimal
    let direction: Direction

    init(current: Decimal, previous: Decimal) {
        difference = abs(current - previous)
        direction = current > previous ? .more : current < previous ? .less : .same
    }
}
