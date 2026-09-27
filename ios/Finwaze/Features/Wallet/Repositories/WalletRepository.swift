import Foundation

protocol WalletRepository: Sendable {
    /// Regular accounts with their balances, sorted by name (`ACC-02`).
    func accounts() async throws -> [WalletAccount]
}
