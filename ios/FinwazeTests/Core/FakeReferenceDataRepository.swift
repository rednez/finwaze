import Foundation
import Synchronization
@testable import Finwaze

struct FakeLoadError: Error {}

final class FakeReferenceDataRepository: AccountsRepository, CategoriesRepository, CurrenciesRepository {
    private struct State {
        var accounts: [Account]
        var fails: Bool
    }

    private let state: Mutex<State>

    init(accounts: [Account] = [], fails: Bool = false) {
        state = Mutex(State(accounts: accounts, fails: fails))
    }

    func setAccounts(_ accounts: [Account]) {
        state.withLock { $0.accounts = accounts }
    }

    func setFails(_ fails: Bool) {
        state.withLock { $0.fails = fails }
    }

    func regularAccounts() async throws -> [Account] {
        let (accounts, fails) = state.withLock { ($0.accounts, $0.fails) }
        if fails { throw FakeLoadError() }
        return accounts
    }

    func groups() async throws -> [CategoryGroup] {
        [CategoryGroup(id: 1, name: "Food", transactionType: .expense, color: nil)]
    }

    func categories() async throws -> [Finwaze.Category] {
        [Finwaze.Category(id: 1, name: "Groceries", groupID: 1, color: nil)]
    }

    func currencies() async throws -> [Currency] {
        [Currency(id: 1, code: "UAH", name: "Hryvnia", countryName: "Ukraine")]
    }
}
