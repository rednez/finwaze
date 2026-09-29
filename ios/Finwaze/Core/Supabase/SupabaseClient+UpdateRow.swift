import Foundation
import Supabase

nonisolated extension SupabaseClient {
    /// Updates the row `id` of `table` with `values`; `false` when the row no longer exists or is not visible under
    /// RLS, e.g. deleted elsewhere.
    func updateRow(_ table: String, id: Int64, values: some Encodable & Sendable) async throws -> Bool {
        let rows: [IDRow] = try await from(table)
            .update(values)
            .eq("id", value: Int(id))
            .select("id")
            .execute()
            .value
        return !rows.isEmpty
    }
}

/// The response of an `update` `select("id")`: present only for rows that still exist and are visible under RLS.
private nonisolated struct IDRow: Decodable {
    let id: Int64
}
