import Foundation

/// Keeps an amount being typed to at most two decimal places (`GEN-07`), so a third digit after the separator never
/// gets in — the field stops it rather than only flagging it.
nonisolated enum AmountInputLimiter {
    static let maxFractionDigits = 2

    /// Drops the digits past the second one after the first separator, `,` or `.` as in `DecimalInputParser`. Text
    /// that is not a number after the separator is left as is, for the validation to report.
    static func limit(_ text: String) -> String {
        guard let separator = text.firstIndex(where: { $0 == "," || $0 == "." }) else { return text }
        let fraction = text[text.index(after: separator)...]
        guard fraction.allSatisfy({ $0.isASCII && $0.isNumber }), fraction.count > maxFractionDigits else { return text }
        return String(text[...separator]) + fraction.prefix(maxFractionDigits)
    }
}
