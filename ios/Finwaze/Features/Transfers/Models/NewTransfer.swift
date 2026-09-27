import Foundation

/// A transfer between two of the user's regular accounts (`TRF-01`). Amounts are positive.
nonisolated struct NewTransfer: Equatable, Sendable {
    let fromAccountID: Int64
    let toAccountID: Int64
    let fromAmount: Decimal
    /// Only when the accounts' currencies differ (`TRF-03`); `nil` lets the server use `fromAmount`.
    let toAmount: Decimal?
    let transactedAt: Date
    let localOffset: LocalOffset
}

/// Parameters of `make_transfer`. `p_comment` is left out: the form has no comment (`Q-05`).
nonisolated struct NewTransferDto: Encodable, Sendable {
    let fromAccountID: Int64
    let toAccountID: Int64
    let fromAmount: Decimal
    /// Left out when `nil`, so the SQL default (`NULL`, the sent amount) applies.
    let toAmount: Decimal?
    /// Interval string such as `"+02:00"`.
    let localOffset: String
    /// ISO 8601 in UTC, sent as text so the encoder's date strategy does not matter.
    let transactedAt: String

    enum CodingKeys: String, CodingKey {
        case fromAccountID = "p_from_account_id"
        case toAccountID = "p_to_account_id"
        case fromAmount = "p_from_amount"
        case toAmount = "p_to_amount"
        case localOffset = "p_local_offset"
        case transactedAt = "p_transacted_at"
    }
}
