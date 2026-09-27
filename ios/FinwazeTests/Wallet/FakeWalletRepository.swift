import Foundation
import Synchronization
@testable import Finwaze

final class FakeWalletRepository: WalletRepository {
    /// One recorded call to `updateAccount(id:_:)`.
    struct UpdateCall: Equatable {
        let id: Int64
        let update: AccountUpdate
    }

    private struct State {
        var accounts: [WalletAccount]
        var fails: Bool
        var loads = 0
        /// Details `accountDetails(id:)` answers with; a missing id answers `nil` ("not found").
        var detailsByID: [Int64: AccountDetails] = [:]
        var updateFails = false
        var adjustFails = false
        var deleteFails = false
        var updated: [UpdateCall] = []
        var adjustments: [BalanceAdjustment] = []
        var deletedIDs: [Int64] = []
    }

    private let state: Mutex<State>

    init(accounts: [WalletAccount] = [], fails: Bool = false) {
        state = Mutex(State(accounts: accounts, fails: fails))
    }

    var loads: Int {
        state.withLock { $0.loads }
    }

    var updated: [UpdateCall] {
        state.withLock { $0.updated }
    }

    var adjustments: [BalanceAdjustment] {
        state.withLock { $0.adjustments }
    }

    var deletedIDs: [Int64] {
        state.withLock { $0.deletedIDs }
    }

    func setAccounts(_ accounts: [WalletAccount]) {
        state.withLock { $0.accounts = accounts }
    }

    func setFails(_ fails: Bool) {
        state.withLock { $0.fails = fails }
    }

    /// What `accountDetails(id:)` answers for `details.id`; leave unset to simulate "not found".
    func setDetails(_ details: AccountDetails) {
        state.withLock { $0.detailsByID[details.id] = details }
    }

    /// Simulates the account being deleted elsewhere after it was loaded: the next update answers "not found".
    func removeDetails(id: Int64) {
        state.withLock { $0.detailsByID[id] = nil }
    }

    func setUpdateFails(_ fails: Bool) {
        state.withLock { $0.updateFails = fails }
    }

    func setAdjustFails(_ fails: Bool) {
        state.withLock { $0.adjustFails = fails }
    }

    func setDeleteFails(_ fails: Bool) {
        state.withLock { $0.deleteFails = fails }
    }

    func accounts() async throws -> [WalletAccount] {
        let (accounts, fails) = state.withLock { state in
            state.loads += 1
            return (state.accounts, state.fails)
        }
        if fails { throw FakeLoadError() }
        return accounts
    }

    func accountDetails(id: Int64) async throws -> AccountDetails? {
        try state.withLock { state in
            if state.fails { throw FakeLoadError() }
            return state.detailsByID[id]
        }
    }

    func updateAccount(id: Int64, _ update: AccountUpdate) async throws -> Bool {
        try state.withLock { state in
            if state.updateFails { throw FakeCreateError() }
            state.updated.append(UpdateCall(id: id, update: update))
            return state.detailsByID[id] != nil
        }
    }

    func adjustBalance(_ adjustment: BalanceAdjustment) async throws {
        try state.withLock { state in
            if state.adjustFails { throw FakeCreateError() }
            state.adjustments.append(adjustment)
        }
    }

    func deleteAccount(id: Int64) async throws {
        try state.withLock { state in
            if state.deleteFails { throw FakeCreateError() }
            state.deletedIDs.append(id)
        }
    }
}
