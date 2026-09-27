import Foundation

/// Nested `select` of one row of `transactions`, as opened for editing (`TX-06`): the same fields
/// `get_filtered_transactions` returns, reached through the table's foreign keys instead of the RPC's flat columns.
nonisolated struct TransactionDetailsDto: Decodable, Sendable {
    struct AccountRef: Decodable, Sendable {
        let id: Int64
        let name: String
    }

    /// Only the code is used: neither the purchase nor the charged currency's id is needed by the domain model.
    struct CurrencyRef: Decodable, Sendable {
        let code: String
    }

    struct GroupRef: Decodable, Sendable {
        let id: Int64
        let name: String
        let color: String?
    }

    struct CategoryRef: Decodable, Sendable {
        let id: Int64
        let name: String
        let color: String?
        let group: GroupRef
    }

    let id: Int64
    let transactedAt: String
    let localOffset: String
    let transactionAmount: Decimal
    let transactionCurrency: CurrencyRef
    let chargedAmount: Decimal
    let chargedCurrency: CurrencyRef
    let type: TransactionType
    let comment: String?
    let transferID: UUID?
    let account: AccountRef
    let category: CategoryRef

    enum CodingKeys: String, CodingKey {
        case id, type, comment, account, category
        case transactedAt = "transacted_at"
        case localOffset = "local_offset"
        case transactionAmount = "transaction_amount"
        case transactionCurrency = "transaction_currency"
        case chargedAmount = "charged_amount"
        case chargedCurrency = "charged_currency"
        case transferID = "transfer_id"
    }
}
