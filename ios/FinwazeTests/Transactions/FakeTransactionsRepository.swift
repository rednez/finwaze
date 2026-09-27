import Foundation
import Synchronization
@testable import Finwaze

final class FakeTransactionsRepository: TransactionsRepository {
    /// One recorded call to `update(id:_:)`.
    struct UpdateCall: Equatable {
        let id: Int64
        let update: TransactionUpdate
    }

    private struct State {
        var transactions: [Transaction]
        var hasTransactions: Bool
        var fails: Bool
        var createFails = false
        var queries: [TransactionQuery] = []
        var created: [NewTransaction] = []
        /// Details `transaction(id:)` answers with; an id missing here answers `nil` ("not found", `TX-42`).
        var detailsByID: [Int64: Transaction] = [:]
        var updateFails = false
        var deleteFails = false
        var requestedIDs: [Int64] = []
        var updated: [UpdateCall] = []
        var deletedIDs: [Int64] = []
    }

    private let state: Mutex<State>

    init(transactions: [Transaction] = [], hasTransactions: Bool = true, fails: Bool = false) {
        state = Mutex(State(transactions: transactions, hasTransactions: hasTransactions, fails: fails))
    }

    /// Queries sent to `transactions(matching:)`, in call order.
    var queries: [TransactionQuery] {
        state.withLock { $0.queries }
    }

    /// Transactions created so far, in call order.
    var created: [NewTransaction] {
        state.withLock { $0.created }
    }

    /// Ids requested through `transaction(id:)`, in call order.
    var requestedIDs: [Int64] {
        state.withLock { $0.requestedIDs }
    }

    /// Calls made to `update(id:_:)`, in call order.
    var updated: [UpdateCall] {
        state.withLock { $0.updated }
    }

    /// Ids passed to `delete(id:)`, in call order.
    var deletedIDs: [Int64] {
        state.withLock { $0.deletedIDs }
    }

    func setTransactions(_ transactions: [Transaction]) {
        state.withLock { $0.transactions = transactions }
    }

    func setFails(_ fails: Bool) {
        state.withLock { $0.fails = fails }
    }

    func setCreateFails(_ fails: Bool) {
        state.withLock { $0.createFails = fails }
    }

    /// What `transaction(id:)` answers for `transaction.id`; leave unset to simulate "not found" (`TX-42`).
    func setDetails(_ transaction: Transaction) {
        state.withLock { $0.detailsByID[transaction.id] = transaction }
    }

    /// Simulates the transaction being deleted elsewhere after it was loaded (`TX-42`): the next `update(id:_:)`
    /// for `id` answers "not found".
    func removeDetails(id: Int64) {
        state.withLock { $0.detailsByID[id] = nil }
    }

    func setUpdateFails(_ fails: Bool) {
        state.withLock { $0.updateFails = fails }
    }

    func setDeleteFails(_ fails: Bool) {
        state.withLock { $0.deleteFails = fails }
    }

    func transactions(matching query: TransactionQuery) async throws -> [Transaction] {
        try state.withLock { state in
            state.queries.append(query)
            if state.fails { throw FakeLoadError() }
            return state.transactions
        }
    }

    func hasTransactions() async throws -> Bool {
        try state.withLock { state in
            if state.fails { throw FakeLoadError() }
            return state.hasTransactions
        }
    }

    func create(_ transaction: NewTransaction) async throws {
        try state.withLock { state in
            state.created.append(transaction)
            if state.createFails { throw FakeCreateError() }
        }
    }

    func transaction(id: Int64) async throws -> Transaction? {
        try state.withLock { state in
            state.requestedIDs.append(id)
            if state.fails { throw FakeLoadError() }
            return state.detailsByID[id]
        }
    }

    func update(id: Int64, _ update: TransactionUpdate) async throws -> Bool {
        try state.withLock { state in
            if state.updateFails { throw FakeCreateError() }
            state.updated.append(UpdateCall(id: id, update: update))
            return state.detailsByID[id] != nil
        }
    }

    func delete(id: Int64) async throws {
        try state.withLock { state in
            if state.deleteFails { throw FakeCreateError() }
            state.deletedIDs.append(id)
        }
    }
}

/// Holds `create(_:)` open until the test resumes it, to observe in-flight state.
final class SuspendedTransactionsRepository: TransactionsRepository {
    private let called = AsyncStream<Void>.makeStream()
    private let release = AsyncStream<Void>.makeStream()
    private let calls = Mutex(0)

    var createCalls: Int {
        calls.withLock { $0 }
    }

    func waitUntilCalled() async {
        var iterator = called.stream.makeAsyncIterator()
        _ = await iterator.next()
    }

    func resume() {
        release.continuation.yield()
    }

    func create(_ transaction: NewTransaction) async throws {
        calls.withLock { $0 += 1 }
        called.continuation.yield()
        var iterator = release.stream.makeAsyncIterator()
        _ = await iterator.next()
    }

    func transactions(matching query: TransactionQuery) async throws -> [Transaction] { [] }

    func hasTransactions() async throws -> Bool { false }

    func transaction(id: Int64) async throws -> Transaction? { nil }

    func update(id: Int64, _ update: TransactionUpdate) async throws -> Bool { false }

    func delete(id: Int64) async throws {}
}

extension Transaction {
    /// A transaction with only the fields a test cares about.
    static func fixture(
        id: Int64 = 1,
        type: TransactionType = .expense,
        amount: Decimal = -250,
        currencyCode: String = "UAH"
    ) -> Transaction {
        Transaction(
            id: id,
            type: type,
            transactedAt: Date(timeIntervalSince1970: 1_790_000_000),
            localOffset: LocalOffset(seconds: 10_800),
            transactionAmount: amount,
            transactionCurrencyCode: currencyCode,
            chargedAmount: amount,
            chargedCurrencyCode: currencyCode,
            accountID: 1,
            accountName: "Cash",
            group: Transaction.Label(id: 1, name: "Food", color: nil),
            category: Transaction.Label(id: 1, name: "Groceries", color: nil),
            comment: nil,
            transferID: nil
        )
    }
}
