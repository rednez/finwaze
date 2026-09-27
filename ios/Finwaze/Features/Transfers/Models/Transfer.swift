import Foundation

/// Both sides of a transfer, as "Transfer details" shows them (`TRF-07`).
nonisolated struct Transfer: Equatable, Sendable {
    /// `transfer_id`, shared by both records; deleting it removes both (`TRF-08`).
    let id: UUID
    /// The outgoing record: a negative amount on the source account.
    let sent: Transaction
    /// The incoming record: a positive amount on the destination account.
    let received: Transaction

    var transactedAt: Date {
        sent.transactedAt
    }

    /// The offset the transfer was made in; its date is shown in it (`GEN-12`).
    var localOffset: LocalOffset {
        sent.localOffset
    }

    var sentAmount: Decimal {
        abs(sent.transactionAmount)
    }

    var receivedAmount: Decimal {
        received.transactionAmount
    }

    /// Received ÷ sent (`TRF-03`, `GEN-10`).
    var exchangeRate: Decimal? {
        sentAmount == 0 ? nil : receivedAmount / sentAmount
    }
}
