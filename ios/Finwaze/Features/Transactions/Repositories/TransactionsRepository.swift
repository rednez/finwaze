import Foundation

protocol TransactionsRepository: Sendable {
    /// Expenses, incomes and transfers matching `query`, newest first by local time (`TX-01`, `GEN-04`, `GEN-12`).
    func transactions(matching query: TransactionQuery) async throws -> [Transaction]
    /// Whether the user has any transaction at all, balance corrections aside (`TX-07`).
    func hasTransactions() async throws -> Bool
    /// Creates an expense or income (`TX-15`).
    func create(_ transaction: NewTransaction) async throws
}
