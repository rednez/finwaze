import Foundation

/// A money amount typed by the user that may be negative, like an account balance on a credit card: required, at
/// most two decimal places (`GEN-07`). A leading `-` or `−` makes it negative.
nonisolated enum SignedAmountInput {
    enum Issue: Error, Equatable, Sendable {
        case required
        /// Not a number: letters, several signs or separators.
        case invalid
        /// More than two decimal places (`GEN-07`).
        case tooPrecise
    }

    static func parse(_ text: String) -> Result<Decimal, Issue> {
        let compact = text.filter { !$0.isWhitespace }
        let isNegative = compact.first == "-" || compact.first == "−"
        let magnitude = isNegative ? String(compact.dropFirst()) : compact

        switch DecimalInputParser.parse(magnitude) {
        case .empty:
            return .failure(isNegative ? .invalid : .required)
        case .invalid:
            return .failure(.invalid)
        case .value(let value, let fractionDigits):
            guard fractionDigits <= 2 else { return .failure(.tooPrecise) }
            return .success(isNegative ? -value : value)
        }
    }
}
