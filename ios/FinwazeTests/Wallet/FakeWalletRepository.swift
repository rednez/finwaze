import Foundation
import Synchronization
@testable import Finwaze

final class FakeWalletRepository: WalletRepository {
    /// One recorded call to `updateAccount(id:_:)`.
    struct UpdateCall: Equatable {
        let id: Int64
        let update: AccountUpdate
    }

    /// One recorded widget request (`ACC-03…05`).
    struct WidgetCall: Equatable {
        let month: YearMonth?
        let currencyCode: String
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
        var dailyCashFlow: [String: [DailyCashFlow]] = [:]
        var recentTransactions: [String: [Transaction]] = [:]
        var amountsByGroup: [String: [GroupAmounts]] = [:]
        var widgetFails = false
        var dailyCashFlowCalls: [WidgetCall] = []
        var recentTransactionsCalls: [WidgetCall] = []
        var amountsByGroupCalls: [WidgetCall] = []
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

    var dailyCashFlowCalls: [WidgetCall] {
        state.withLock { $0.dailyCashFlowCalls }
    }

    var recentTransactionsCalls: [WidgetCall] {
        state.withLock { $0.recentTransactionsCalls }
    }

    var amountsByGroupCalls: [WidgetCall] {
        state.withLock { $0.amountsByGroupCalls }
    }

    /// What the widgets answer for a currency, whatever the month; a currency left unset answers empty.
    func setDailyCashFlow(_ days: [DailyCashFlow], currencyCode: String) {
        state.withLock { $0.dailyCashFlow[currencyCode] = days }
    }

    func setRecentTransactions(_ transactions: [Transaction], currencyCode: String) {
        state.withLock { $0.recentTransactions[currencyCode] = transactions }
    }

    func setAmountsByGroup(_ groups: [GroupAmounts], currencyCode: String) {
        state.withLock { $0.amountsByGroup[currencyCode] = groups }
    }

    func setWidgetFails(_ fails: Bool) {
        state.withLock { $0.widgetFails = fails }
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

    func dailyCashFlow(month: YearMonth, currencyCode: String) async throws -> [DailyCashFlow] {
        try state.withLock { state in
            state.dailyCashFlowCalls.append(WidgetCall(month: month, currencyCode: currencyCode))
            if state.widgetFails { throw FakeLoadError() }
            return state.dailyCashFlow[currencyCode] ?? []
        }
    }

    func recentTransactions(currencyCode: String, limit: Int) async throws -> [Transaction] {
        try state.withLock { state in
            state.recentTransactionsCalls.append(WidgetCall(month: nil, currencyCode: currencyCode))
            if state.widgetFails { throw FakeLoadError() }
            return Array((state.recentTransactions[currencyCode] ?? []).prefix(limit))
        }
    }

    func amountsByGroup(month: YearMonth, currencyCode: String) async throws -> [GroupAmounts] {
        try state.withLock { state in
            state.amountsByGroupCalls.append(WidgetCall(month: month, currencyCode: currencyCode))
            if state.widgetFails { throw FakeLoadError() }
            return state.amountsByGroup[currencyCode] ?? []
        }
    }
}
