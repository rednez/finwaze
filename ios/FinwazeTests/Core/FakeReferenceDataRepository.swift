import Foundation
import Synchronization
@testable import Finwaze

struct FakeLoadError: Error {}

struct FakeCreateError: LocalizedError {
    var errorDescription: String? { "duplicate key value" }
}

final class FakeReferenceDataRepository: AccountsRepository, CategoriesRepository, CurrenciesRepository {
    static let uah = Currency(id: 1, code: "UAH", name: "Hryvnia", countryName: "Ukraine")
    static let eur = Currency(id: 2, code: "EUR", name: "Euro", countryName: "European Union")

    static let food = CategoryGroup(id: 1, name: "Food", transactionType: .expense, color: nil)
    static let salary = CategoryGroup(id: 2, name: "Salary", transactionType: .income, color: nil)
    static let groceries = Finwaze.Category(id: 1, name: "Groceries", groupID: 1, color: "#22C55E")
    static let paycheck = Finwaze.Category(id: 2, name: "Paycheck", groupID: 2, color: nil)

    private struct State {
        var accounts: [Account]
        var groups: [CategoryGroup]
        var categories: [Finwaze.Category]
        var fails: Bool
        var createFails = false
        var created: [(name: String, currencyID: Int64)] = []
    }

    private let state: Mutex<State>

    init(
        accounts: [Account] = [],
        groups: [CategoryGroup] = [food],
        categories: [Finwaze.Category] = [groceries],
        fails: Bool = false
    ) {
        state = Mutex(State(accounts: accounts, groups: groups, categories: categories, fails: fails))
    }

    /// Accounts created so far, in call order.
    var created: [(name: String, currencyID: Int64)] {
        state.withLock { $0.created }
    }

    func setAccounts(_ accounts: [Account]) {
        state.withLock { $0.accounts = accounts }
    }

    func setFails(_ fails: Bool) {
        state.withLock { $0.fails = fails }
    }

    func setCreateFails(_ fails: Bool) {
        state.withLock { $0.createFails = fails }
    }

    func regularAccounts() async throws -> [Account] {
        let (accounts, fails) = state.withLock { ($0.accounts, $0.fails) }
        if fails { throw FakeLoadError() }
        return accounts
    }

    /// Like the server: the new account shows up in `regularAccounts()` from now on.
    func createAccount(name: String, currencyID: Int64) async throws -> Account {
        try state.withLock { state in
            state.created.append((name, currencyID))
            if state.createFails { throw FakeCreateError() }
            let code = [Self.uah, Self.eur].first { $0.id == currencyID }?.code ?? "?"
            let account = Account(id: Int64(100 + state.accounts.count), name: name, currencyCode: code)
            state.accounts.append(account)
            return account
        }
    }

    func groups() async throws -> [CategoryGroup] {
        state.withLock { $0.groups }
    }

    func categories() async throws -> [Finwaze.Category] {
        state.withLock { $0.categories }
    }

    /// Like the server: the new group shows up in `groups()` from now on.
    func createGroup(name: String, type: TransactionType, color: String?) async throws -> CategoryGroup {
        try state.withLock { state in
            if state.createFails { throw FakeCreateError() }
            let group = CategoryGroup(id: Int64(100 + state.groups.count), name: name, transactionType: type, color: color)
            state.groups.append(group)
            return group
        }
    }

    /// Like the server: the new category shows up in `categories()` from now on.
    func createCategory(name: String, groupID: Int64, color: String?) async throws -> Finwaze.Category {
        try state.withLock { state in
            if state.createFails { throw FakeCreateError() }
            let category = Finwaze.Category(id: Int64(100 + state.categories.count), name: name, groupID: groupID, color: color)
            state.categories.append(category)
            return category
        }
    }

    func currencies() async throws -> [Currency] {
        [Self.uah, Self.eur]
    }
}
