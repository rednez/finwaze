import Foundation

/// Reads an amount typed by the user into a `Decimal`, never through `Double` (`GEN-07`, `GEN-09`).
nonisolated enum DecimalInputParser {
    enum Result: Equatable {
        case empty
        /// Not a plain unsigned number: letters, a sign, several separators.
        case invalid
        case value(Decimal, fractionDigits: Int)
    }

    /// Accepts digits with one decimal separator, either `,` or `.`, whatever the language — the decimal pad shows the
    /// locale's one, and pasted text may have the other. Spaces (grouping in `1 250,50`) are ignored.
    static func parse(_ text: String) -> Result {
        let compact = text.filter { !$0.isWhitespace }
        guard !compact.isEmpty else { return .empty }
        guard let match = compact.wholeMatch(of: /(\d+)(?:[.,](\d+))?/) else { return .invalid }

        let fraction = match.2.map(String.init) ?? ""
        let normalized = fraction.isEmpty ? String(match.1) : "\(match.1).\(fraction)"
        guard let value = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")) else { return .invalid }
        return .value(value, fractionDigits: fraction.count)
    }
}
