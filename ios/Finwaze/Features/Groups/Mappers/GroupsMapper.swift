import Foundation

nonisolated enum GroupsMapper {
    static func toGroup(_ dto: GroupWithCategoriesDto) -> GroupWithCategories {
        GroupWithCategories(
            id: dto.id,
            name: dto.name,
            transactionType: dto.transactionType,
            color: dto.color,
            categories: dto.categories.map {
                GroupWithCategories.Item(id: $0.id, name: $0.name, color: $0.color, transactionsCount: $0.transactionsCount)
            }
        )
    }

    /// Groups in creation order, like the web and the category picker.
    static func sorted(_ groups: [GroupWithCategories]) -> [GroupWithCategories] {
        groups.sorted { $0.id < $1.id }
    }
}
