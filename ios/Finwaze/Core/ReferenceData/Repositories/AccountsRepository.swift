import Foundation

protocol AccountsRepository: Sendable {
    /// Regular accounts only; savings-goal accounts are excluded.
    func regularAccounts() async throws -> [Account]
    /// Creates a regular account with a zero balance (`ACC-07`, `ONB-02`).
    func createAccount(name: String, currencyID: Int64) async throws -> Account
}
