import Foundation

/// Insert payload for `accounts`.
nonisolated struct NewAccountDto: Encodable, Sendable {
    let name: String
    let currencyID: Int64

    enum CodingKeys: String, CodingKey {
        case name
        case currencyID = "currency_id"
    }
}
