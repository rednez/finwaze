import Foundation

nonisolated enum TransferMapper {
    /// Pairs the records of one transfer: the negative one was sent, the positive one received. `nil` unless both
    /// are there and share a `transfer_id` — a transfer deleted elsewhere yields no rows (`TRF-08`).
    static func toTransfer(_ transactions: [Transaction]) -> Transfer? {
        let transfers = transactions.filter { $0.type == .transfer }
        guard
            let sent = transfers.first(where: { $0.transactionAmount < 0 }),
            let received = transfers.first(where: { $0.transactionAmount > 0 }),
            let id = sent.transferID,
            received.transferID == id
        else { return nil }
        return Transfer(id: id, sent: sent, received: received)
    }

    static func toDto(_ transfer: NewTransfer) -> NewTransferDto {
        NewTransferDto(
            fromAccountID: transfer.fromAccountID,
            toAccountID: transfer.toAccountID,
            fromAmount: transfer.fromAmount,
            toAmount: transfer.toAmount,
            localOffset: transfer.localOffset.intervalString,
            // With the `Z` designator: without it Postgres would read the time in the session's time zone.
            transactedAt: Date.ISO8601FormatStyle(includingFractionalSeconds: true, timeZone: .gmt)
                .format(transfer.transactedAt)
        )
    }
}
