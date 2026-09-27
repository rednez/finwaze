import Foundation

/// An entry of the full currency directory, e.g. "USD – US Dollar".
nonisolated struct Currency: Identifiable, Equatable, Hashable, Sendable {
    let id: Int64
    let code: String
    let name: String
    let countryName: String
}
