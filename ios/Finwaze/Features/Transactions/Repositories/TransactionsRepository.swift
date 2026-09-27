import Foundation

protocol TransactionsRepository: Sendable {
    /// Expenses, incomes and transfers matching `query`, newest first by local time (`TX-01`, `GEN-04`, `GEN-12`).
    func transactions(matching query: TransactionQuery) async throws -> [Transaction]
    /// Whether the user has any transaction at all, balance corrections aside (`TX-07`).
    func hasTransactions() async throws -> Bool
    /// Creates an expense or income (`TX-15`).
    func create(_ transaction: NewTransaction) async throws
    /// Fresh details of one transaction, read straight from the server, not the list (`TX-06`); `nil` when it no
    /// longer exists (`TX-42`).
    func transaction(id: Int64) async throws -> Transaction?
    /// Saves changes to an expense or income (`TX-40`); `false` when it no longer exists (`TX-42`).
    func update(id: Int64, _ update: TransactionUpdate) async throws -> Bool
    /// Deletes a transaction (`TX-41`); deleting one that is already gone still succeeds.
    func delete(id: Int64) async throws
}
