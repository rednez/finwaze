import Foundation

/// Pushes "Edit transaction" onto a section's navigation stack (`TX-06`). A transfer has no destination yet
/// (`TRF-07`, stage 5).
nonisolated struct TransactionRoute: Hashable {
    let id: Int64
}
