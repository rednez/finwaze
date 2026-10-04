import Foundation

/// Pushes "Edit transaction" onto a section's navigation stack (`TX-06`).
nonisolated struct TransactionRoute: Hashable {
    let id: Int64
    /// The transaction as the list showed it, so the form is there from the first frame of the zoom while the fresh
    /// copy loads. Not part of the route's identity.
    var preview: Transaction?

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// Pushes "Transfer details" for the transfer that the record `transactionID` belongs to (`TX-06`, `TRF-07`).
nonisolated struct TransferRoute: Hashable {
    let transactionID: Int64
}
