import Foundation
import Synchronization
@testable import Finwaze

final class FakeTransactionsRepository: TransactionsRepository {
    private struct State {
        var transactions: [Transaction]
        var hasTransactions: Bool
        var fails: Bool
        var createFails = false
        var queries: [TransactionQuery] = []
        var created: [NewTransaction] = []
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

    func setTransactions(_ transactions: [Transaction]) {
        state.withLock { $0.transactions = transactions }
    }

    func setFails(_ fails: Bool) {
        state.withLock { $0.fails = fails }
    }

    func setCreateFails(_ fails: Bool) {
        state.withLock { $0.createFails = fails }
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
