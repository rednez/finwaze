import Foundation

nonisolated extension Decimal {
    /// An amount with its currency, formatted for the interface language: `1 250,00 ₴`, `€5.00` (`GEN-06`, `GEN-18`).
    func formattedAmount(currencyCode: String, locale: Locale = .current) -> String {
        formatted(.currency(code: currencyCode).locale(locale))
    }
}
