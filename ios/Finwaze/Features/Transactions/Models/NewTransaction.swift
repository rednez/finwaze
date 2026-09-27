import Foundation

/// An expense or income to create (`TX-15`). Amounts are positive; the server stores an expense as negative (`TX-24`).
nonisolated struct NewTransaction: Equatable, Sendable {
    let type: TransactionType
    let transactedAt: Date
    let localOffset: LocalOffset
    let accountID: Int64
    let categoryID: Int64
    let transactionAmount: Decimal
    let transactionCurrencyID: Int64
    /// Equals `transactionAmount` while the purchase currency is the account's (`TX-23`).
    let chargedAmount: Decimal
    let comment: String?
}

/// Insert payload for `transactions`. `charged_currency_id` is set by a trigger from the account.
nonisolated struct NewTransactionDto: Encodable, Sendable {
    let type: TransactionType
    /// ISO 8601 in UTC, sent as text so the encoder's date strategy does not matter.
    let transactedAt: String
    /// Interval string such as `"+02:00"`.
    let localOffset: String
    let accountID: Int64
    let categoryID: Int64
    let transactionAmount: Decimal
    let transactionCurrencyID: Int64
    let chargedAmount: Decimal
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case type, comment
        case transactedAt = "transacted_at"
        case localOffset = "local_offset"
        case accountID = "account_id"
        case categoryID = "category_id"
        case transactionAmount = "transaction_amount"
        case transactionCurrencyID = "transaction_currency_id"
        case chargedAmount = "charged_amount"
    }
}
