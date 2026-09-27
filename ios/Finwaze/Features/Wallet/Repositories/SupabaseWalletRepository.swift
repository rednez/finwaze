import Foundation
import Supabase

nonisolated struct SupabaseWalletRepository: WalletRepository {
    let client: SupabaseClient

    func accounts() async throws -> [WalletAccount] {
        let dtos: [WalletAccountDto] = try await client
            .from("regular_accounts_with_balance")
            .select("id, name, currency_code, balance")
            .execute()
            .value
        return WalletMapper.sortedByName(dtos.map(WalletMapper.toAccount))
    }
}
