import Foundation
import Supabase

/// The repositories the app works with. Each stage adds its repositories to both sets:
/// `live` talks to Supabase, `demo` serves local demo data and turns every write into a no-op (`AUTH-10`).
nonisolated struct Repositories: Sendable {
    let accounts: any AccountsRepository
    let categories: any CategoriesRepository
    let currencies: any CurrenciesRepository

    static func live(client: SupabaseClient) -> Repositories {
        Repositories(
            accounts: SupabaseAccountsRepository(client: client),
            categories: SupabaseCategoriesRepository(client: client),
            currencies: SupabaseCurrenciesRepository(client: client)
        )
    }

    static let demo: Repositories = {
        let repository = DemoReferenceDataRepository()
        return Repositories(accounts: repository, categories: repository, currencies: repository)
    }()
}
