import Foundation

protocol WalletRepository: Sendable {
    /// Regular accounts with their balances, sorted by name (`ACC-02`).
    func accounts() async throws -> [WalletAccount]
    /// One regular account, fresh from the server (`ACC-09`); `nil` when it no longer exists.
    func accountDetails(id: Int64) async throws -> AccountDetails?
    /// Renames the account and, if given, changes its currency (`ACC-09`, `ACC-10`); `false` when it no longer
    /// exists.
    func updateAccount(id: Int64, _ update: AccountUpdate) async throws -> Bool
    /// Sets the balance at a moment; the server adds a hidden correction for the difference, if any (`ACC-09`).
    func adjustBalance(_ adjustment: BalanceAdjustment) async throws
    /// Deletes an account without transactions, together with its corrections (`ACC-11`).
    func deleteAccount(id: Int64) async throws
    /// Incomes and expenses in a purchase currency for every day of the month (`ACC-03`).
    func dailyCashFlow(month: YearMonth, currencyCode: String) async throws -> [DailyCashFlow]
    /// The newest transactions in a purchase currency, newest first, without balance corrections (`ACC-04`).
    func recentTransactions(currencyCode: String, limit: Int) async throws -> [Transaction]
    /// Incomes and expenses in a purchase currency over the month by group (`ACC-05`).
    func amountsByGroup(month: YearMonth, currencyCode: String) async throws -> [GroupAmounts]
}
