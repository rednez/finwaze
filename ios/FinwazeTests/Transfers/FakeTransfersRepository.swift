import Foundation
import Synchronization
@testable import Finwaze

final class FakeTransfersRepository: TransfersRepository {
    private struct State {
        var makeFails = false
        var loadFails = false
        var deleteFails = false
        var made: [NewTransfer] = []
        /// Details `transfer(transactionID:)` answers with, by the id of either record; a missing id answers `nil`.
        var transfersByTransactionID: [Int64: Transfer] = [:]
        var requestedIDs: [Int64] = []
        var deletedIDs: [UUID] = []
    }

    private let state = Mutex(State())

    /// Transfers made so far, in call order.
    var made: [NewTransfer] {
        state.withLock { $0.made }
    }

    /// Ids requested through `transfer(transactionID:)`, in call order.
    var requestedIDs: [Int64] {
        state.withLock { $0.requestedIDs }
    }

    /// Transfer ids passed to `delete(transferID:)`, in call order.
    var deletedIDs: [UUID] {
        state.withLock { $0.deletedIDs }
    }

    func setMakeFails(_ fails: Bool) {
        state.withLock { $0.makeFails = fails }
    }

    func setLoadFails(_ fails: Bool) {
        state.withLock { $0.loadFails = fails }
    }

    func setDeleteFails(_ fails: Bool) {
        state.withLock { $0.deleteFails = fails }
    }

    /// What `transfer(transactionID:)` answers for the ids of both records; leave unset to simulate "not found".
    func setDetails(_ transfer: Transfer) {
        state.withLock {
            $0.transfersByTransactionID[transfer.sent.id] = transfer
            $0.transfersByTransactionID[transfer.received.id] = transfer
        }
    }

    func make(_ transfer: NewTransfer) async throws {
        try state.withLock { state in
            if state.makeFails { throw FakeCreateError() }
            state.made.append(transfer)
        }
    }

    func transfer(transactionID: Int64) async throws -> Transfer? {
        try state.withLock { state in
            state.requestedIDs.append(transactionID)
            if state.loadFails { throw FakeLoadError() }
            return state.transfersByTransactionID[transactionID]
        }
    }

    func delete(transferID: UUID) async throws {
        try state.withLock { state in
            if state.deleteFails { throw FakeCreateError() }
            state.deletedIDs.append(transferID)
        }
    }
}

extension Transfer {
    /// 100 USD sent from "Card" (id 1) and 4 150 UAH received in "Cash" (id 2), unless told otherwise.
    static func fixture(
        sentID: Int64 = 11,
        receivedID: Int64 = 12,
        sent: Decimal = 100,
        received: Decimal = 4150,
        sentCurrency: String = "USD",
        receivedCurrency: String = "UAH"
    ) -> Transfer {
        let id = UUID(uuidString: "3F2504E0-4F89-41D3-9A0C-0305E82C3301")!
        return Transfer(
            id: id,
            sent: .transferRecord(id: sentID, transferID: id, amount: -sent, currencyCode: sentCurrency, accountID: 1, accountName: "Card"),
            received: .transferRecord(id: receivedID, transferID: id, amount: received, currencyCode: receivedCurrency, accountID: 2, accountName: "Cash")
        )
    }
}

extension Transaction {
    /// One record of a transfer.
    static func transferRecord(
        id: Int64,
        transferID: UUID,
        amount: Decimal,
        currencyCode: String,
        accountID: Int64,
        accountName: String
    ) -> Transaction {
        let system = Transaction.Label(id: 99, name: "internal", color: nil)
        return Transaction(
            id: id,
            type: .transfer,
            transactedAt: Date(timeIntervalSince1970: 1_790_000_000),
            localOffset: LocalOffset(seconds: 10_800),
            transactionAmount: amount,
            transactionCurrencyCode: currencyCode,
            chargedAmount: amount,
            chargedCurrencyCode: currencyCode,
            accountID: accountID,
            accountName: accountName,
            group: system,
            category: system,
            comment: nil,
            transferID: transferID
        )
    }
}
