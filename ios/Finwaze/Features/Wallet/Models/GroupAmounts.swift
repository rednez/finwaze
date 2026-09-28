import Foundation

/// A group's incomes and expenses in one purchase currency over a month, for the Wallet's "Statistics" (`ACC-05`).
nonisolated struct GroupAmounts: Identifiable, Equatable, Sendable {
    let id: Int64
    let name: String
    let income: Decimal
    /// As a positive amount.
    let expense: Decimal
}
