import Foundation

nonisolated extension Decimal {
    /// An amount with its currency, formatted for the interface language: `1 250,00 ₴`, `€5.00` (`GEN-06`, `GEN-18`).
    func formattedAmount(currencyCode: String, locale: Locale = .current) -> String {
        formatted(.currency(code: currencyCode).locale(locale))
    }

    /// Like `formattedAmount`, but a positive amount gets an explicit plus: `+$3,200.00` for an income (`GEN-08`).
    func formattedSignedAmount(currencyCode: String, locale: Locale = .current) -> String {
        formatted(.currency(code: currencyCode).sign(strategy: .always(showZero: false)).locale(locale))
    }

    /// The amount as the user would type it in the interface language, without grouping, to prefill a field:
    /// `4101,10`, `-300`.
    func inputText(locale: Locale = .current) -> String {
        var value = self
        var whole = Decimal()
        NSDecimalRound(&whole, &value, 0, .plain)
        let fraction = whole == self ? 0 : 2
        return formatted(.number.precision(.fractionLength(fraction)).grouping(.never).locale(locale))
    }
}

nonisolated extension Decimal {
    /// An exchange rate as a plain number with `fractionLength` decimal places, for the interface language:
    /// `43,1250` (`GEN-10`).
    func formattedExchangeRate(fractionLength: ClosedRange<Int> = 2...4, locale: Locale = .current) -> String {
        formatted(.number.precision(.fractionLength(fractionLength)).locale(locale))
    }

    /// The rate as a sentence between two currencies: `1 EUR = 43,1250 UAH` (`GEN-10`).
    func formattedExchangeRate(
        from sourceCode: String,
        to targetCode: String,
        fractionLength: ClosedRange<Int> = 2...4,
        locale: Locale = .current
    ) -> String {
        "1 \(sourceCode) = \(formattedExchangeRate(fractionLength: fractionLength, locale: locale)) \(targetCode)"
    }
}
