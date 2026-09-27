import Foundation

/// Demo transactions, generated for any month from the same template as the web client's
/// (`TX_DEFS` in `src/app/core/services/demo-mode/demo-data.ts`).
nonisolated extension DemoData {
    private struct Template {
        let day: Int
        let type: TransactionType
        let categoryID: Int64
        /// Positive for an income, negative for an expense.
        let amount: Decimal
    }

    private static let templates = [
        Template(day: 1, type: .income, categoryID: 8, amount: 3200),
        Template(day: 3, type: .expense, categoryID: 7, amount: -1200),
        Template(day: 5, type: .expense, categoryID: 1, amount: -85),
        Template(day: 8, type: .expense, categoryID: 3, amount: -15),
        Template(day: 10, type: .expense, categoryID: 2, amount: -45),
        Template(day: 12, type: .expense, categoryID: 6, amount: -20),
        Template(day: 15, type: .expense, categoryID: 1, amount: -65),
        Template(day: 18, type: .expense, categoryID: 4, amount: -5),
        Template(day: 20, type: .expense, categoryID: 5, amount: -30),
        Template(day: 22, type: .expense, categoryID: 1, amount: -55),
        Template(day: 25, type: .expense, categoryID: 3, amount: -18),
        Template(day: 28, type: .expense, categoryID: 2, amount: -40),
    ]

    /// The month's transactions on the Main Card (USD), newest first. None in the future: a later month is empty
    /// and the current one stops at `now`.
    static func transactions(inMonthOf month: Date, now: Date = .now, calendar: Calendar = .current) -> [Transaction] {
        guard
            let interval = calendar.dateInterval(of: .month, for: month),
            interval.start <= now
        else { return [] }

        let account = accounts[0]
        let components = calendar.dateComponents([.year, .month], from: interval.start)
        let firstID = Int64((components.year ?? 0) * 100 + (components.month ?? 0)) * 100

        let oldestFirst = templates.enumerated().compactMap { index, template -> Transaction? in
            // Noon, so the day stays the same in the device's local time.
            guard
                let date = calendar.date(byAdding: DateComponents(day: template.day - 1, hour: 12), to: interval.start),
                date < interval.end,
                date <= now,
                let category = categories.first(where: { $0.id == template.categoryID }),
                let group = groups.first(where: { $0.id == category.groupID })
            else { return nil }

            return Transaction(
                id: firstID + Int64(index),
                type: template.type,
                transactedAt: date,
                localOffset: LocalOffset(seconds: calendar.timeZone.secondsFromGMT(for: date)),
                transactionAmount: template.amount,
                transactionCurrencyCode: account.currencyCode,
                chargedAmount: template.amount,
                chargedCurrencyCode: account.currencyCode,
                accountID: account.id,
                accountName: account.name,
                group: Transaction.Label(id: group.id, name: group.name, color: group.color),
                category: Transaction.Label(id: category.id, name: category.name, color: category.color),
                comment: nil,
                transferID: nil
            )
        }
        return oldestFirst.reversed()
    }
}
