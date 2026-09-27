import Foundation

/// Demo-mode groups and categories: built from `DemoData`, never from the network (`AUTH-10`).
nonisolated struct DemoGroupsRepository: GroupsRepository {
    func groups() async throws -> [GroupWithCategories] {
        let groups = DemoData.groups.map { group in
            GroupWithCategories(
                id: group.id,
                name: group.name,
                transactionType: group.transactionType,
                color: group.color,
                categories: DemoData.categories.filter { $0.groupID == group.id }.map {
                    GroupWithCategories.Item(
                        id: $0.id,
                        name: $0.name,
                        color: $0.color,
                        transactionsCount: DemoData.monthlyTransactionCount(categoryID: $0.id)
                    )
                }
            )
        }
        return GroupsMapper.sorted(groups)
    }

    /// A no-op, like on the web: nothing is stored, so the demo never changes.
    func updateGroup(id: Int64, name: String, color: String?) async throws -> Bool {
        true
    }

    /// A no-op, like `updateGroup`.
    func deleteGroup(id: Int64) async throws {}

    /// A no-op, like `updateGroup`.
    func updateCategory(id: Int64, name: String, color: String?) async throws -> Bool {
        true
    }

    /// A no-op, like `updateGroup`.
    func deleteCategory(id: Int64) async throws {}
}
