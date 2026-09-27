import Foundation

nonisolated struct GroupDto: Decodable, Sendable {
    let id: Int64
    let name: String
    let transactionType: TransactionType
    let color: String?

    enum CodingKeys: String, CodingKey {
        case id, name, color
        case transactionType = "transaction_type"
    }
}
