import Foundation

/// The transactions of one day, by the local time they happened in (`GEN-12`).
nonisolated struct TransactionDay: Identifiable, Equatable, Sendable {
    /// `YYYY-MM-DD` of the local day.
    let id: String
    private(set) var transactions: [Transaction]

    /// A transaction of the day, to format its date in the day's local time.
    var first: Transaction {
        transactions[0]
    }

    /// Splits a newest-first list into days, keeping the order. A day is taken in each transaction's own offset, so
    /// 00:30 on the 1st local time belongs to the 1st even if it was still the 31st in UTC.
    static func group(_ transactions: [Transaction]) -> [TransactionDay] {
        var days: [TransactionDay] = []
        for transaction in transactions {
            let key = transaction.transactedAt.isoDateString(in: transaction.localOffset.timeZone)
            if days.last?.id == key {
                days[days.count - 1].transactions.append(transaction)
            } else {
                days.append(TransactionDay(id: key, transactions: [transaction]))
            }
        }
        return days
    }
}

/// Income and expenses of a list, when they can be added up: incomes and expenses only (`GEN-02`) and all in one
/// currency — amounts in different currencies are never summed.
nonisolated struct TransactionTotals: Equatable, Sendable {
    let income: Decimal
    /// Negative, as stored.
    let expenses: Decimal
    let currencyCode: String

    var net: Decimal {
        income + expenses
    }

    /// `nil` when there is nothing to add up or the currencies differ. Transfers and balance corrections are left
    /// out by type; income and expense are told apart by the sign of the amount.
    static func of(_ transactions: [Transaction]) -> TransactionTotals? {
        let counted = transactions.filter(\.isCounted)
        guard
            let currencyCode = counted.first?.transactionCurrencyCode,
            counted.allSatisfy({ $0.transactionCurrencyCode == currencyCode })
        else { return nil }

        let amounts = counted.map(\.transactionAmount)
        return TransactionTotals(
            income: amounts.filter { $0 > 0 }.reduce(0, +),
            expenses: amounts.filter { $0 < 0 }.reduce(0, +),
            currencyCode: currencyCode
        )
    }
}
