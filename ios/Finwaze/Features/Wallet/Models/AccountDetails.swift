import Foundation

/// One regular account as "Account settings" edits it (`ACC-09…11`), read fresh from the server.
nonisolated struct AccountDetails: Identifiable, Equatable, Sendable {
    let id: Int64
    let name: String
    let currencyID: Int64
    let currencyCode: String
    /// Sum of all the account's records, balance corrections included (`GEN-03`).
    let balance: Decimal
    /// No income, expense or transfer on the account — corrections aside. Only then can its currency change or the
    /// account be deleted (`ACC-10`, `ACC-11`).
    let canDelete: Bool
}

/// Row of `get_regular_account_with_balance`.
nonisolated struct AccountDetailsDto: Decodable, Sendable {
    let id: Int64
    let name: String
    let currencyID: Int64
    let currencyCode: String
    /// `NUMERIC`: `JSONDecoder` reads the JSON number text straight into `Decimal`, with no `Double` in between.
    let balance: Decimal
    let canDelete: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, balance
        case currencyID = "currency_id"
        case currencyCode = "currency_code"
        case canDelete = "can_delete"
    }
}
