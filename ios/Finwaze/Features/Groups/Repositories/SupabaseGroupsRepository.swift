import Foundation
import Supabase

nonisolated struct SupabaseGroupsRepository: GroupsRepository {
    let client: SupabaseClient

    func groups() async throws -> [GroupWithCategories] {
        let dtos: [GroupWithCategoriesDto] = try await client
            .from("groups_with_categories_tx_counts")
            .select("id, name, color, transaction_type, categories")
            .execute()
            .value
        return GroupsMapper.sorted(dtos.map(GroupsMapper.toGroup))
    }

    func updateGroup(id: Int64, name: String, color: String?) async throws -> Bool {
        try await update(table: "groups", id: id, name: name, color: color)
    }

    func deleteGroup(id: Int64) async throws {
        try await client.from("groups").delete().eq("id", value: Int(id)).execute()
    }

    func updateCategory(id: Int64, name: String, color: String?) async throws -> Bool {
        try await update(table: "categories", id: id, name: name, color: color)
    }

    func deleteCategory(id: Int64) async throws {
        try await client.from("categories").delete().eq("id", value: Int(id)).execute()
    }

    /// One request for both the name and the colour; the web sends them separately.
    private func update(table: String, id: Int64, name: String, color: String?) async throws -> Bool {
        try await client.updateRow(table, id: id, values: NameColorUpdateDto(name: name, color: color))
    }
}
