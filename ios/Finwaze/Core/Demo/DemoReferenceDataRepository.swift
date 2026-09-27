import Foundation

/// Demo-mode reference data: served from `DemoData`, never from the network (`AUTH-10`, `Q-08`).
nonisolated struct DemoReferenceDataRepository: AccountsRepository, CategoriesRepository, CurrenciesRepository {
    func regularAccounts() async throws -> [Account] {
        DemoData.accounts
    }

    func groups() async throws -> [CategoryGroup] {
        DemoData.groups
    }

    func categories() async throws -> [Category] {
        DemoData.categories
    }

    func currencies() async throws -> [Currency] {
        DemoData.currencies
    }
}
