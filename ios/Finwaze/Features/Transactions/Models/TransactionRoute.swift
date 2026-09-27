import Foundation

/// Pushes "Edit transaction" onto a section's navigation stack (`TX-06`).
nonisolated struct TransactionRoute: Hashable {
    let id: Int64
}

/// Pushes "Transfer details" for the transfer that the record `transactionID` belongs to (`TX-06`, `TRF-07`).
nonisolated struct TransferRoute: Hashable {
    let transactionID: Int64
}
