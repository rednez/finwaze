import Foundation

/// Insert payload for `groups`.
nonisolated struct NewGroupDto: Encodable, Sendable {
    let name: String
    let transactionType: TransactionType
    /// `#RRGGBB`; left out when `nil`, so the column stays `NULL`.
    let color: String?

    enum CodingKeys: String, CodingKey {
        case name, color
        case transactionType = "transaction_type"
    }
}

/// Insert payload for `categories`.
nonisolated struct NewCategoryDto: Encodable, Sendable {
    let name: String
    let groupID: Int64
    /// `#RRGGBB`; left out when `nil`, so the column stays `NULL`.
    let color: String?

    enum CodingKeys: String, CodingKey {
        case name, color
        case groupID = "group_id"
    }
}
