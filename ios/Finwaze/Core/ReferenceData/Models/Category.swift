import Foundation

/// A category within a group, e.g. "Fuel" in "Car".
nonisolated struct Category: Identifiable, Equatable, Hashable, Sendable {
    let id: Int64
    let name: String
    let groupID: Int64
    /// Hex colour from the fixed palette, if any.
    let color: String?
}
