import Foundation

protocol AccountsRepository: Sendable {
    /// Regular accounts only; savings-goal accounts are excluded.
    func regularAccounts() async throws -> [Account]
}
