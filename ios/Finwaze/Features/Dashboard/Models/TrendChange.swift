import Foundation

/// The change badge of a summary card against last month (`DASH-03`), like the web's `FinancialTrendBadge`.
nonisolated struct TrendChange: Equatable, Sendable {
    enum Direction: Equatable, Sendable {
        case up, down, flat
    }

    enum Assessment: Equatable, Sendable {
        case good, bad, neutral
    }

    /// The size of the change as a fraction of last month's value: 0.125 for 12.5 %. Never negative.
    let ratio: Decimal
    let direction: Direction
    let assessment: Assessment

    /// Change = (current − previous) ÷ |previous|, so a negative balance that shrinks still reads as growth.
    /// A previous value of 0 gives no change: 0 % and neutral.
    /// - Parameter growthIsGood: `true` for the balance and income, `false` for expenses.
    init(current: Decimal, previous: Decimal, growthIsGood: Bool) {
        guard previous != 0, current != previous else {
            ratio = 0
            direction = .flat
            assessment = .neutral
            return
        }
        let delta = (current - previous) / abs(previous)
        ratio = abs(delta)
        direction = delta > 0 ? .up : .down
        assessment = (delta > 0) == growthIsGood ? .good : .bad
    }

    /// "12.5 %" in the interface language, with at most one decimal place (`GEN-18`).
    func formattedRatio(locale: Locale = .current) -> String {
        ratio.formatted(.percent.precision(.fractionLength(0...1)).locale(locale))
    }
}
