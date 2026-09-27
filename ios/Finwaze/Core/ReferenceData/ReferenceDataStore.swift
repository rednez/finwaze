import Foundation
import Observation

/// Data most screens need, loaded right after sign-in (`NAV-10`): accounts, groups and categories, currencies.
@Observable
final class ReferenceDataStore {
    private(set) var accounts: [Account] = []
    private(set) var groups: [CategoryGroup] = []
    private(set) var categories: [Category] = []
    private(set) var currencies: [Currency] = []

    /// Currencies of the user's accounts, without repeats, in account order (`GEN-11`).
    var accountCurrencyCodes: [String] {
        var seen = Set<String>()
        return accounts.map(\.currencyCode).filter { seen.insert($0).inserted }
    }

    /// Loads everything at once from `repositories` (live or demo); on failure the previous data stays as it was.
    func load(using repositories: Repositories) async throws {
        async let accounts = repositories.accounts.regularAccounts()
        async let groups = repositories.categories.groups()
        async let categories = repositories.categories.categories()
        async let currencies = repositories.currencies.currencies()

        let loaded = try await (accounts, groups, categories, currencies)
        (self.accounts, self.groups, self.categories, self.currencies) = loaded
    }

    func reset() {
        accounts = []
        groups = []
        categories = []
        currencies = []
    }
}
