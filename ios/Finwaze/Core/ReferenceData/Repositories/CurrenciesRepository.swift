import Foundation

protocol CurrenciesRepository: Sendable {
    /// The full currency directory.
    func currencies() async throws -> [Currency]
}
