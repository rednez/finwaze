import Foundation

/// A money amount typed by the user: required, greater than zero, at most two decimal places (`GEN-07`).
nonisolated enum PositiveAmountInput {
    enum Issue: Error, Equatable, Sendable {
        case required
        /// Not a number, signed, zero or below.
        case notPositive
        /// More than two decimal places (`GEN-07`).
        case tooPrecise
    }

    static func parse(_ text: String) -> Result<Decimal, Issue> {
        switch DecimalInputParser.parse(text) {
        case .empty:
            .failure(.required)
        case .invalid:
            .failure(.notPositive)
        case .value(let value, let fractionDigits):
            if value <= 0 {
                .failure(.notPositive)
            } else if fractionDigits > 2 {
                .failure(.tooPrecise)
            } else {
                .success(value)
            }
        }
    }
}
