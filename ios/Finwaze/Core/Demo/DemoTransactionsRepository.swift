import Foundation

/// Demo-mode transactions: generated from `DemoData`, never from the network (`AUTH-10`).
/// Unlike the web demo, the filters apply, so the demo shows how they work.
nonisolated struct DemoTransactionsRepository: TransactionsRepository {
    var calendar: Calendar = .current
    var now: @Sendable () -> Date = { .now }

    func transactions(matching query: TransactionQuery) async throws -> [Transaction] {
        DemoData.transactions(inMonthOf: query.month, now: now(), calendar: calendar).filter { $0.matches(query) }
    }

    func hasTransactions() async throws -> Bool {
        true
    }

    /// A no-op, like on the web: nothing is stored, so the demo never changes.
    func create(_ transaction: NewTransaction) async throws {}
}

private nonisolated extension Transaction {
    /// The server's filtering of `get_filtered_transactions`, done locally.
    func matches(_ query: TransactionQuery) -> Bool {
        if let type = query.type, type != self.type { return false }
        if let categoryIDs = query.categoryIDs, !categoryIDs.contains(category.id) { return false }
        if let currencyCode = query.currencyCode, currencyCode != transactionCurrencyCode { return false }
        if let accountID = query.accountID, accountID != self.accountID { return false }
        return true
    }
}
