import Foundation
import Supabase

nonisolated struct SupabaseCurrenciesRepository: CurrenciesRepository {
    let client: SupabaseClient

    func currencies() async throws -> [Currency] {
        let dtos: [CurrencyDto] = try await client
            .from("currencies")
            .select("id, code, name, country_name")
            .order("code")
            .execute()
            .value
        return dtos.map(ReferenceDataMapper.toCurrency)
    }
}
