import Foundation

/// A row of the transactions list: an expense, an income or one side of a transfer (`TX-01`, `TX-02`).
/// Amounts are signed as stored: an expense and an outgoing transfer are negative.
nonisolated struct Transaction: Identifiable, Equatable, Sendable {
    /// A group or category as the list shows it.
    struct Label: Equatable, Sendable {
        let id: Int64
        let name: String
        /// Hex colour from the fixed palette, if any.
        let color: String?
    }

    let id: Int64
    let type: TransactionType
    let transactedAt: Date
    /// The user's offset when the transaction happened; dates are shown in it (`GEN-12`).
    let localOffset: LocalOffset
    /// Amount in the purchase currency.
    let transactionAmount: Decimal
    let transactionCurrencyCode: String
    /// Amount charged to the account, in its currency.
    let chargedAmount: Decimal
    let chargedCurrencyCode: String
    let accountID: Int64
    let accountName: String
    let group: Label
    let category: Label
    let comment: String?
    let transferID: UUID?

    /// Charged ÷ purchase amount, shown when the two currencies differ (`GEN-10`).
    var exchangeRate: Decimal? {
        transactionAmount == 0 ? nil : chargedAmount / transactionAmount
    }

    var isForeignCurrency: Bool {
        transactionCurrencyCode != chargedCurrencyCode
    }
}

nonisolated extension Transaction {
    /// Whether it counts as an income or expense: transfers and balance corrections never do (`GEN-02`).
    var isCounted: Bool {
        type != .transfer && type != .internal
    }

    /// A counted record with a positive `amount`: incomes and expenses are told apart by sign, not by type (`GEN-02`).
    func isIncome(by amount: KeyPath<Transaction, Decimal>) -> Bool {
        isCounted && self[keyPath: amount] > 0
    }

    /// A counted record with a negative `amount` (`GEN-02`).
    func isExpense(by amount: KeyPath<Transaction, Decimal>) -> Bool {
        isCounted && self[keyPath: amount] < 0
    }
}

nonisolated extension Sequence<Transaction> {
    /// The total of the incomes by `amount` (`GEN-02`).
    func income(_ amount: KeyPath<Transaction, Decimal>) -> Decimal {
        filter { $0.isIncome(by: amount) }.reduce(0) { $0 + $1[keyPath: amount] }
    }

    /// The total of the expenses by `amount`, as a positive amount (`GEN-02`).
    func expense(_ amount: KeyPath<Transaction, Decimal>) -> Decimal {
        abs(filter { $0.isExpense(by: amount) }.reduce(0) { $0 + $1[keyPath: amount] })
    }
}
