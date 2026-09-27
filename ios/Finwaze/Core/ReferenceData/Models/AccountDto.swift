import Foundation

/// Row of `accounts` selected as `id, name, currencies(code)`.
nonisolated struct AccountDto: Decodable, Sendable {
    struct CurrencyCode: Decodable, Sendable {
        let code: String
    }

    let id: Int64
    let name: String
    let currencies: CurrencyCode
}
