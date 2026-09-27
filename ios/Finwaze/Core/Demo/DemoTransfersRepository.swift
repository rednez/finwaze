import Foundation

/// Demo-mode transfers: the monthly transfer from `DemoData`, never from the network (`AUTH-10`).
nonisolated struct DemoTransfersRepository: TransfersRepository {
    var calendar: Calendar = .current
    var now: @Sendable () -> Date = { .now }

    /// A no-op, like on the web: nothing is stored, so the demo never changes.
    func make(_ transfer: NewTransfer) async throws {}

    func transfer(transactionID: Int64) async throws -> Transfer? {
        let month = DemoData.monthTransactions(containing: transactionID, now: now(), calendar: calendar)
        guard let transferID = month.first(where: { $0.id == transactionID })?.transferID else { return nil }
        return TransferMapper.toTransfer(month.filter { $0.transferID == transferID })
    }

    /// A no-op, like `make`: the "deleted" transfer stays in place (`AUTH-10`).
    func delete(transferID: UUID) async throws {}
}
