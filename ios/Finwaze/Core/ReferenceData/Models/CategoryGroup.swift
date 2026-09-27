import Foundation

/// A user-defined group of categories, e.g. "Car". Named `CategoryGroup` to avoid clashing with SwiftUI's `Group`.
nonisolated struct CategoryGroup: Identifiable, Equatable, Hashable, Sendable {
    let id: Int64
    let name: String
    let transactionType: TransactionType
    /// Hex colour from the fixed palette, if any.
    let color: String?
}
