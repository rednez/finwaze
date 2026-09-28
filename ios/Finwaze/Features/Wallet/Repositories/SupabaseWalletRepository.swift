import Foundation
import Supabase

nonisolated struct SupabaseWalletRepository: WalletRepository {
    let client: SupabaseClient

    private struct DetailsParams: Encodable {
        let accountID: Int64

        enum CodingKeys: String, CodingKey {
            case accountID = "p_account_id"
        }
    }

    /// The response of an `update` `select("id")`: present only for rows that still exist and are visible under RLS.
    private struct IDRow: Decodable {
        let id: Int64
    }

    func accounts() async throws -> [WalletAccount] {
        let dtos: [WalletAccountDto] = try await client
            .from("regular_accounts_with_balance")
            .select("id, name, currency_code, balance")
            .execute()
            .value
        return WalletMapper.sortedByName(dtos.map(WalletMapper.toAccount))
    }

    func accountDetails(id: Int64) async throws -> AccountDetails? {
        // An array, not `.single()`: a deleted account simply yields zero rows, not an error.
        let dtos: [AccountDetailsDto] = try await client
            .rpc("get_regular_account_with_balance", params: DetailsParams(accountID: id))
            .execute()
            .value
        return dtos.first.map(WalletMapper.toDetails)
    }

    func updateAccount(id: Int64, _ update: AccountUpdate) async throws -> Bool {
        let rows: [IDRow] = try await client
            .from("accounts")
            .update(WalletMapper.toDto(update))
            .eq("id", value: Int(id))
            .select("id")
            .execute()
            .value
        return !rows.isEmpty
    }

    func adjustBalance(_ adjustment: BalanceAdjustment) async throws {
        try await client
            .rpc("adjust_account_balance", params: WalletMapper.toDto(adjustment))
            .execute()
    }

    /// Like the web: the corrections first, then the account — the only records it may still have (`ACC-11`).
    /// Not atomic: see `ios/docs/TECH_DEBT.md`.
    func deleteAccount(id: Int64) async throws {
        try await client
            .from("transactions")
            .delete()
            .eq("account_id", value: Int(id))
            .eq("type", value: TransactionType.internal.rawValue)
            .execute()
        try await client
            .from("accounts")
            .delete()
            .eq("id", value: Int(id))
            .execute()
    }
}
