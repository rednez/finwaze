import Foundation
import Supabase

/// The repositories the app works with. Each stage adds its repositories to both sets:
/// `live` talks to Supabase, `demo` serves local demo data and turns every write into a no-op (`AUTH-10`).
nonisolated struct Repositories: Sendable {
    let accounts: any AccountsRepository
    let categories: any CategoriesRepository
    let currencies: any CurrenciesRepository
    let wallet: any WalletRepository
    let transactions: any TransactionsRepository
    let transfers: any TransfersRepository
    let groups: any GroupsRepository
    let dashboard: any DashboardRepository
    let budget: any BudgetRepository
    let goals: any GoalsRepository
    let analytics: any AnalyticsRepository

    static func live(client: SupabaseClient) -> Repositories {
        Repositories(
            accounts: SupabaseAccountsRepository(client: client),
            categories: SupabaseCategoriesRepository(client: client),
            currencies: SupabaseCurrenciesRepository(client: client),
            wallet: SupabaseWalletRepository(client: client),
            transactions: SupabaseTransactionsRepository(client: client),
            transfers: SupabaseTransfersRepository(client: client),
            groups: SupabaseGroupsRepository(client: client),
            dashboard: SupabaseDashboardRepository(client: client),
            budget: SupabaseBudgetRepository(client: client),
            goals: SupabaseGoalsRepository(client: client),
            analytics: SupabaseAnalyticsRepository(client: client)
        )
    }

    static let demo: Repositories = {
        let repository = DemoReferenceDataRepository()
        return Repositories(
            accounts: repository,
            categories: repository,
            currencies: repository,
            wallet: DemoWalletRepository(),
            transactions: DemoTransactionsRepository(),
            transfers: DemoTransfersRepository(),
            groups: DemoGroupsRepository(),
            dashboard: DemoDashboardRepository(),
            budget: DemoBudgetRepository(),
            goals: DemoGoalsRepository(),
            analytics: DemoAnalyticsRepository()
        )
    }()
}
