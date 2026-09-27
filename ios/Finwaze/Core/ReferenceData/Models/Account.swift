import Foundation

/// A regular account (bank, card, cash). Savings-goal accounts are not part of reference data.
nonisolated struct Account: Identifiable, Equatable, Hashable, Sendable {
    let id: Int64
    let name: String
    let currencyCode: String
}
