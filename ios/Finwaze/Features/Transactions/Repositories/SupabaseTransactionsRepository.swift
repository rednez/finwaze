import Foundation
import Supabase

nonisolated struct SupabaseTransactionsRepository: TransactionsRepository {
    let client: SupabaseClient

    /// The nested `select` behind `transaction(id:)`, wider than the web's so it also carries the group's and
    /// category's colour (`TX-06`).
    private static let detailsSelect = """
        id, transacted_at, local_offset, transaction_amount, charged_amount, type, comment, transfer_id,
        account:accounts!transactions_account_id_fkey(id, name),
        transaction_currency:currencies!transactions_transaction_currency_id_fkey(code),
        charged_currency:currencies!transactions_charged_currency_id_fkey(code),
        category:categories!transactions_category_id_fkey(id, name, color,
          group:groups!categories_group_id_fkey(id, name, color)
        )
        """

    /// The response of an `update`/`insert` `select("id")`: present only for rows that still exist and are visible
    /// under RLS.
    private struct IDRow: Decodable {
        let id: Int64
    }

    /// Parameters of `get_filtered_transactions`; a `nil` one is left out, so the SQL default (`NULL`, "any") applies.
    private struct Params: Encodable {
        let month: String
        let type: TransactionType?
        let categoryIDs: [Int64]?
        let currencyCodes: [String]?
        let accountIDs: [Int64]?

        enum CodingKeys: String, CodingKey {
            case month = "p_month"
            case type = "p_transaction_type"
            case categoryIDs = "p_category_ids"
            case currencyCodes = "p_transaction_currency_codes"
            case accountIDs = "p_account_ids"
        }
    }

    func transactions(matching query: TransactionQuery) async throws -> [Transaction] {
        let dtos: [TransactionDto] = try await client
            .rpc("get_filtered_transactions", params: Self.params(for: query))
            .execute()
            .value
        return try dtos.map(TransactionMapper.toTransaction)
    }

    func hasTransactions() async throws -> Bool {
        let response = try await client
            .from("transactions")
            .select("id", head: true, count: .exact)
            .neq("type", value: TransactionType.internal.rawValue)
            .execute()
        return (response.count ?? 0) > 0
    }

    func create(_ transaction: NewTransaction) async throws {
        // `user_id` defaults to `auth.uid()`, like the web insert.
        try await client
            .from("transactions")
            .insert(TransactionMapper.toDto(transaction))
            .execute()
    }

    func transaction(id: Int64) async throws -> Transaction? {
        // An array, not `.single()`: RLS or a deletion elsewhere simply yields zero rows, not an error (`TX-42`).
        let dtos: [TransactionDetailsDto] = try await client
            .from("transactions")
            .select(Self.detailsSelect)
            .eq("id", value: Int(id))
            .execute()
            .value
        guard let dto = dtos.first else { return nil }
        return try TransactionMapper.toTransaction(dto)
    }

    func update(id: Int64, _ update: TransactionUpdate) async throws -> Bool {
        let rows: [IDRow] = try await client
            .from("transactions")
            .update(TransactionMapper.toDto(update))
            .eq("id", value: Int(id))
            .select("id")
            .execute()
            .value
        return !rows.isEmpty
    }

    func delete(id: Int64) async throws {
        try await client
            .from("transactions")
            .delete()
            .eq("id", value: Int(id))
            .execute()
    }

    /// The whole month in one call, like the web (`Q-07`): no `p_page_size`.
    private static func params(for query: TransactionQuery) -> Params {
        Params(
            month: query.month.isoDateString(),
            type: query.type,
            categoryIDs: query.categoryIDs,
            currencyCodes: query.currencyCode.map { [$0] },
            accountIDs: query.accountID.map { [$0] }
        )
    }
}
