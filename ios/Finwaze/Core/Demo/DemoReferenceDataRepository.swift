import Foundation

/// Demo-mode reference data: served from `DemoData`, never from the network (`AUTH-10`, `Q-08`).
nonisolated struct DemoReferenceDataRepository: AccountsRepository, CategoriesRepository, CurrenciesRepository {
    func regularAccounts() async throws -> [Account] {
        DemoData.accounts
    }

    /// A no-op, like on the web: answers with a made-up account and stores nothing, so the demo never changes.
    func createAccount(name: String, currencyID: Int64) async throws -> Account {
        let code = DemoData.currencies.first { $0.id == currencyID }?.code ?? ""
        return Account(id: DemoData.createdRowID, name: name, currencyCode: code)
    }

    func groups() async throws -> [CategoryGroup] {
        DemoData.groups
    }

    func categories() async throws -> [Category] {
        DemoData.categories
    }

    /// A no-op: answers with a made-up group and stores nothing.
    func createGroup(name: String, type: TransactionType, color: String?) async throws -> CategoryGroup {
        CategoryGroup(id: DemoData.createdRowID, name: name, transactionType: type, color: color)
    }

    /// A no-op: answers with a made-up category and stores nothing.
    func createCategory(name: String, groupID: Int64, color: String?) async throws -> Category {
        Category(id: DemoData.createdRowID, name: name, groupID: groupID, color: color)
    }

    func currencies() async throws -> [Currency] {
        DemoData.currencies
    }
}
