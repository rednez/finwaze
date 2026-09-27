import Foundation

/// Row of the `regular_accounts_with_balance` view.
nonisolated struct WalletAccountDto: Decodable, Sendable {
    let id: Int64
    let name: String
    let currencyCode: String
    /// `NUMERIC`: `JSONDecoder` reads the JSON number text straight into `Decimal`, with no `Double` in between.
    let balance: Decimal

    enum CodingKeys: String, CodingKey {
        case id, name, balance
        case currencyCode = "currency_code"
    }
}
