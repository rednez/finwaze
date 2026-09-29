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

    private struct MonthParams: Encodable {
        let month: String
        let currencyCode: String

        enum CodingKeys: String, CodingKey {
            case month = "p_month"
            case currencyCode = "p_currency_code"
        }
    }

    private struct RecentParams: Encodable {
        let currencyCodes: [String]
        let pageSize: Int

        enum CodingKeys: String, CodingKey {
            case currencyCodes = "p_transaction_currency_codes"
            case pageSize = "p_page_size"
        }
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
        try await client.updateRow("accounts", id: id, values: WalletMapper.toDto(update))
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

    func dailyCashFlow(month: YearMonth, currencyCode: String) async throws -> [DailyCashFlow] {
        let dtos: [DailyCashFlowDto] = try await client
            .rpc(
                "get_daily_transactions_cash_flow_for_month",
                params: MonthParams(month: month.firstDayParameter, currencyCode: currencyCode)
            )
            .execute()
            .value
        return try dtos.map { try WalletMapper.toDailyCashFlow($0) }
    }

    func recentTransactions(currencyCode: String, limit: Int) async throws -> [Transaction] {
        // Like the web: the transactions list's function, by purchase currency, first page only.
        let dtos: [TransactionDto] = try await client
            .rpc("get_filtered_transactions", params: RecentParams(currencyCodes: [currencyCode], pageSize: limit))
            .execute()
            .value
        return try dtos.map(TransactionMapper.toTransaction)
    }

    func amountsByGroup(month: YearMonth, currencyCode: String) async throws -> [GroupAmounts] {
        let dtos: [GroupAmountsDto] = try await client
            .rpc(
                "get_monthly_transaction_amounts_by_group",
                params: MonthParams(month: month.firstDayParameter, currencyCode: currencyCode)
            )
            .execute()
            .value
        return dtos.map(WalletMapper.toGroupAmounts)
    }
}
