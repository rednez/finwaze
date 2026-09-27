import Foundation

/// A group with its categories as the "Groups & categories" screen shows them (`CAT-02`, `CAT-03`).
nonisolated struct GroupWithCategories: Identifiable, Equatable, Sendable {
    /// A category with the number of transactions filed under it.
    struct Item: Identifiable, Equatable, Sendable {
        let id: Int64
        let name: String
        /// Hex colour from the fixed palette, if any.
        let color: String?
        let transactionsCount: Int

        /// Only a category without transactions can be deleted (`CAT-09`).
        var canDelete: Bool {
            transactionsCount == 0
        }
    }

    let id: Int64
    let name: String
    let transactionType: TransactionType
    /// Hex colour from the fixed palette, if any.
    let color: String?
    let categories: [Item]

    /// Only a group without categories can be deleted (`CAT-06`).
    var canDelete: Bool {
        categories.isEmpty
    }
}

/// Row of the `groups_with_categories_tx_counts` view: system groups and categories are already left out
/// (`GEN-05`).
nonisolated struct GroupWithCategoriesDto: Decodable, Sendable {
    struct CategoryDto: Decodable, Sendable {
        let id: Int64
        let name: String
        let color: String?
        let transactionsCount: Int

        enum CodingKeys: String, CodingKey {
            case id, name, color
            case transactionsCount = "transactions_count"
        }
    }

    let id: Int64
    let name: String
    let transactionType: TransactionType
    let color: String?
    /// A `jsonb` array, empty for a group without categories.
    let categories: [CategoryDto]

    enum CodingKeys: String, CodingKey {
        case id, name, color, categories
        case transactionType = "transaction_type"
    }
}

/// Update payload for `groups` and `categories`. `color` is always sent, `null` included, so "no colour" clears it
/// (`CAT-10`).
nonisolated struct NameColorUpdateDto: Encodable, Sendable {
    let name: String
    let color: String?

    enum CodingKeys: String, CodingKey {
        case name, color
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
    }
}
