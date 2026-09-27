import Foundation

/// Row of `get_filtered_transactions`.
nonisolated struct TransactionDto: Decodable, Sendable {
    let id: Int64
    /// `TIMESTAMPTZ` as PostgREST sends it; parsed by the mapper.
    let transactedAt: String
    /// `INTERVAL`, e.g. `"02:00:00"`.
    let localOffset: String
    /// `NUMERIC`: `JSONDecoder` reads the JSON number text straight into `Decimal`, with no `Double` in between.
    let transactionAmount: Decimal
    let transactionCurrencyCode: String
    let accountID: Int64
    let accountName: String
    let chargedAmount: Decimal
    let chargedCurrencyCode: String
    let type: TransactionType
    let groupID: Int64
    let groupName: String
    let groupColor: String?
    let categoryID: Int64
    let categoryName: String
    let categoryColor: String?
    let comment: String?
    let transferID: UUID?

    enum CodingKeys: String, CodingKey {
        case id, type, comment
        case transactedAt = "transacted_at"
        case localOffset = "local_offset"
        case transactionAmount = "transaction_amount"
        case transactionCurrencyCode = "transaction_currency_code"
        case accountID = "account_id"
        case accountName = "account_name"
        case chargedAmount = "charged_amount"
        case chargedCurrencyCode = "charged_currency_code"
        case groupID = "group_id"
        case groupName = "group_name"
        case groupColor = "group_color"
        case categoryID = "category_id"
        case categoryName = "category_name"
        case categoryColor = "category_color"
        case transferID = "transfer_id"
    }
}
