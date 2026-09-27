import Foundation

nonisolated struct CurrencyDto: Decodable, Sendable {
    let id: Int64
    let code: String
    let name: String
    let countryName: String

    enum CodingKeys: String, CodingKey {
        case id, code, name
        case countryName = "country_name"
    }
}
