import Foundation

/// Picks the primary currency (`NAV-11`).
nonisolated enum PrimaryCurrencyResolver {
    /// Keeps the stored currency while some account still uses it; otherwise falls back to the first
    /// account's currency. `nil` only when there are no accounts.
    static func resolve(stored: String?, accounts: [Account]) -> String? {
        if let stored, accounts.contains(where: { $0.currencyCode == stored }) {
            return stored
        }
        return accounts.first?.currencyCode
    }
}
