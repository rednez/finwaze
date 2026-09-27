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

    private struct State {
        var accounts: [Account]
        var fails: Bool
        var createFails = false
        var created: [(name: String, currencyID: Int64)] = []
    }

    private let state: Mutex<State>

    init(accounts: [Account] = [], fails: Bool = false) {
        state = Mutex(State(accounts: accounts, fails: fails))
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
        [CategoryGroup(id: 1, name: "Food", transactionType: .expense, color: nil)]
    }

    func categories() async throws -> [Finwaze.Category] {
        [Finwaze.Category(id: 1, name: "Groceries", groupID: 1, color: nil)]
    }

    func currencies() async throws -> [Currency] {
        [Self.uah, Self.eur]
    }
}
