import Foundation

/// A regular account on the Wallet screen, with its current balance (`ACC-02`).
nonisolated struct WalletAccount: Identifiable, Equatable, Hashable, Sendable {
    let id: Int64
    let name: String
    let currencyCode: String
    /// Sum of all the account's transactions, in its own currency.
    let balance: Decimal
}
