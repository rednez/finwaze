import Foundation
import Supabase

nonisolated struct SupabaseTransactionsRepository: TransactionsRepository {
    let client: SupabaseClient

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
