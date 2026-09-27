import Foundation

/// Changes to an existing expense or income (`TX-40`). Amounts are positive, like `NewTransaction`; the type
/// itself never changes (`TX-40`) and stays out of the payload.
nonisolated struct TransactionUpdate: Equatable, Sendable {
    let transactedAt: Date
    /// The transaction's own offset, unless the user changed the date/time — never the device's current one
    /// (`GEN-12`).
    let localOffset: LocalOffset
    let accountID: Int64
    let categoryID: Int64
    let transactionAmount: Decimal
    let transactionCurrencyID: Int64
    /// Equals `transactionAmount` while the purchase currency is the account's (`TX-23`).
    let chargedAmount: Decimal
    let comment: String?
}

/// Update payload for `transactions`. `charged_currency_id` is set by a trigger from the account.
nonisolated struct TransactionUpdateDto: Encodable, Sendable {
    let transactedAt: String
    let localOffset: String
    let accountID: Int64
    let categoryID: Int64
    let transactionAmount: Decimal
    let transactionCurrencyID: Int64
    let chargedAmount: Decimal
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case comment
        case transactedAt = "transacted_at"
        case localOffset = "local_offset"
        case accountID = "account_id"
        case categoryID = "category_id"
        case transactionAmount = "transaction_amount"
        case transactionCurrencyID = "transaction_currency_id"
        case chargedAmount = "charged_amount"
    }
}
