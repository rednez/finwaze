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

    func createAccount(name: String, currencyID: Int64) async throws -> Account {
        // `type` defaults to `regular` and `user_id` to `auth.uid()`, like the web insert.
        let dto: AccountDto = try await client
            .from("accounts")
            .insert(NewAccountDto(name: name, currencyID: currencyID))
            .select("id, name, currencies(code)")
            .single()
            .execute()
            .value
        return ReferenceDataMapper.toAccount(dto)
    }
}
