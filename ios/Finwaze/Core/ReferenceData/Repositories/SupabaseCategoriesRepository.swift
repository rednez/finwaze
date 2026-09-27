import Foundation
import Supabase

nonisolated struct SupabaseCategoriesRepository: CategoriesRepository {
    let client: SupabaseClient

    func groups() async throws -> [CategoryGroup] {
        let dtos: [GroupDto] = try await client
            .from("groups")
            .select("id, name, transaction_type, color")
            .eq("is_system", value: false)
            .order("id")
            .execute()
            .value
        return dtos.map(ReferenceDataMapper.toGroup)
    }

    func categories() async throws -> [Category] {
        let dtos: [CategoryDto] = try await client
            .from("categories")
            .select("id, name, group_id, color")
            .eq("is_system", value: false)
            .order("id")
            .execute()
            .value
        return dtos.map(ReferenceDataMapper.toCategory)
    }

    func createGroup(name: String, type: TransactionType, color: String?) async throws -> CategoryGroup {
        // `is_system` defaults to false and `user_id` to `auth.uid()`, like the web insert.
        let dto: GroupDto = try await client
            .from("groups")
            .insert(NewGroupDto(name: name, transactionType: type, color: color))
            .select("id, name, transaction_type, color")
            .single()
            .execute()
            .value
        return ReferenceDataMapper.toGroup(dto)
    }

    func createCategory(name: String, groupID: Int64, color: String?) async throws -> Category {
        let dto: CategoryDto = try await client
            .from("categories")
            .insert(NewCategoryDto(name: name, groupID: groupID, color: color))
            .select("id, name, group_id, color")
            .single()
            .execute()
            .value
        return ReferenceDataMapper.toCategory(dto)
    }
}
