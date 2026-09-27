import Foundation
import Synchronization
@testable import Finwaze

final class FakeWalletRepository: WalletRepository {
    private struct State {
        var accounts: [WalletAccount]
        var fails: Bool
        var loads = 0
    }

    private let state: Mutex<State>

    init(accounts: [WalletAccount] = [], fails: Bool = false) {
        state = Mutex(State(accounts: accounts, fails: fails))
    }

    var loads: Int {
        state.withLock { $0.loads }
    }

    func setAccounts(_ accounts: [WalletAccount]) {
        state.withLock { $0.accounts = accounts }
    }

    func setFails(_ fails: Bool) {
        state.withLock { $0.fails = fails }
    }

    func accounts() async throws -> [WalletAccount] {
        let (accounts, fails) = state.withLock { state in
            state.loads += 1
            return (state.accounts, state.fails)
        }
        if fails { throw FakeLoadError() }
        return accounts
    }
}
