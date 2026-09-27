import Foundation

/// New name and, when it may still change, currency of a regular account (`ACC-09`, `ACC-10`).
nonisolated struct AccountUpdate: Equatable, Sendable {
    let name: String
    /// `nil` keeps the current currency: it cannot change once the account has transactions (`ACC-10`).
    let currencyID: Int64?
}

/// Update payload for `accounts`; a `nil` currency is left out, so the column keeps its value.
nonisolated struct AccountUpdateDto: Encodable, Sendable {
    let name: String
    let currencyID: Int64?

    enum CodingKeys: String, CodingKey {
        case name
        case currencyID = "currency_id"
    }
}

/// A new balance for an account at a moment (`ACC-09`); the server records the difference as a hidden correction.
nonisolated struct BalanceAdjustment: Equatable, Sendable {
    let accountID: Int64
    /// May be negative, e.g. a credit card.
    let targetBalance: Decimal
    let balanceDate: Date
    let localOffset: LocalOffset
}

/// Parameters of `adjust_account_balance`. `p_comment` is left out, like on the web.
nonisolated struct BalanceAdjustmentDto: Encodable, Sendable {
    let accountID: Int64
    let targetBalance: Decimal
    /// Interval string such as `"+02:00"`.
    let localOffset: String
    /// ISO 8601 in UTC, sent as text so the encoder's date strategy does not matter.
    let balanceDate: String

    enum CodingKeys: String, CodingKey {
        case accountID = "p_account_id"
        case targetBalance = "p_target_balance"
        case localOffset = "p_local_offset"
        case balanceDate = "p_balance_date"
    }
}
