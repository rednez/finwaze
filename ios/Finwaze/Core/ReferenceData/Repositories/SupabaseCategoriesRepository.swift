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
}
