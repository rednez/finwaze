import Foundation
import Synchronization
@testable import Finwaze

/// Holds `createAccount(name:currencyID:)` open until the test resumes it, to observe in-flight state.
final class SuspendedAccountsRepository: AccountsRepository {
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

    func createAccount(name: String, currencyID: Int64) async throws -> Account {
        calls.withLock { $0 += 1 }
        called.continuation.yield()
        var iterator = release.stream.makeAsyncIterator()
        _ = await iterator.next()
        return Account(id: 1, name: name, currencyCode: "UAH")
    }

    func regularAccounts() async throws -> [Account] { [] }
}
