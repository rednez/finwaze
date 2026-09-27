import Foundation

/// A row of the transactions list: an expense, an income or one side of a transfer (`TX-01`, `TX-02`).
/// Amounts are signed as stored: an expense and an outgoing transfer are negative.
nonisolated struct Transaction: Identifiable, Equatable, Sendable {
    /// A group or category as the list shows it.
    struct Label: Equatable, Sendable {
        let id: Int64
        let name: String
        /// Hex colour from the fixed palette, if any.
        let color: String?
    }

    let id: Int64
    let type: TransactionType
    let transactedAt: Date
    /// The user's offset when the transaction happened; dates are shown in it (`GEN-12`).
    let localOffset: LocalOffset
    /// Amount in the purchase currency.
    let transactionAmount: Decimal
    let transactionCurrencyCode: String
    /// Amount charged to the account, in its currency.
    let chargedAmount: Decimal
    let chargedCurrencyCode: String
    let accountID: Int64
    let accountName: String
    let group: Label
    let category: Label
    let comment: String?
    let transferID: UUID?

    /// Charged ÷ purchase amount, shown when the two currencies differ (`GEN-10`).
    var exchangeRate: Decimal? {
        transactionAmount == 0 ? nil : chargedAmount / transactionAmount
    }

    var isForeignCurrency: Bool {
        transactionCurrencyCode != chargedCurrencyCode
    }
}
