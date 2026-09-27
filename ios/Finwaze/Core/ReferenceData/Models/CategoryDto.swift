import Foundation

nonisolated struct CategoryDto: Decodable, Sendable {
    let id: Int64
    let name: String
    let groupID: Int64
    let color: String?

    enum CodingKeys: String, CodingKey {
        case id, name, color
        case groupID = "group_id"
    }
}
