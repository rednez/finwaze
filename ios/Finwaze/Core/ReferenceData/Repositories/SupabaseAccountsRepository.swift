import Foundation
import Supabase

nonisolated struct SupabaseAccountsRepository: AccountsRepository {
    let client: SupabaseClient

    func regularAccounts() async throws -> [Account] {
        let dtos: [AccountDto] = try await client
            .from("accounts")
            .select("id, name, currencies(code)")
            .eq("type", value: "regular")
            // Oldest first: the first account decides the default primary currency (`NAV-11`).
            .order("id")
            .execute()
            .value
        return dtos.map(ReferenceDataMapper.toAccount)
    }
}
