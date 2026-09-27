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

    /// A transfer made every month on this day: 100 USD from the Main Card to 4 150 UAH in Cash (`TRF-06`, `TRF-07`).
    /// Unlike the web demo, which has none, so the demo shows transfer rows and their details.
    private static let transferDay = 14
    private static let transferSent: Decimal = 100
    private static let transferReceived: Decimal = 4150
    /// Id offsets of the transfer's two records within the month, clear of the template's `0..<templates.count`.
    private static let transferSentIndex: Int64 = 50
    private static let transferReceivedIndex: Int64 = 51

    /// How many times the category occurs in a month of demo transactions — the count "Groups & categories" shows
    /// (`CAT-03`). Every demo category occurs, so none can be deleted.
    static func monthlyTransactionCount(categoryID: Int64) -> Int {
        templates.count { $0.categoryID == categoryID }
    }

    /// Accounts the demo transactions and transfers touch: the Main Card and Cash. Only the others can change their
    /// currency or be deleted (`ACC-10`, `ACC-11`).
    static let accountIDsWithTransactions: Set<Int64> = [accounts[0].id, accounts[1].id]

    /// The system category transfers are filed under; the list shows "Transfer" instead (`GEN-05`, `TX-02`).
    private static let transferLabel = Transaction.Label(id: 0, name: "internal", color: nil)

    /// The month's transactions: the template on the Main Card (USD) and the monthly transfer, newest first. None in
    /// the future: a later month is empty and the current one stops at `now`.
    static func transactions(inMonthOf month: Date, now: Date = .now, calendar: Calendar = .current) -> [Transaction] {
        guard
            let interval = calendar.dateInterval(of: .month, for: month),
            interval.start <= now
        else { return [] }

        let account = accounts[0]
        let components = calendar.dateComponents([.year, .month], from: interval.start)
        let firstID = Int64((components.year ?? 0) * 100 + (components.month ?? 0)) * 100

        let templated = templates.enumerated().compactMap { index, template -> Transaction? in
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
        let all = templated + transfer(
            on: calendar.date(byAdding: DateComponents(day: transferDay - 1, hour: 12), to: interval.start),
            firstID: firstID,
            within: interval,
            now: now,
            calendar: calendar
        )
        return all.sorted { ($0.transactedAt, $0.id) > ($1.transactedAt, $1.id) }
    }

    /// Looks the id up in its own month: the id encodes it (`YYYYMM · 100 + n`, see `transactions(inMonthOf:)`).
    static func transaction(id: Int64, now: Date = .now, calendar: Calendar = .current) -> Transaction? {
        monthTransactions(containing: id, now: now, calendar: calendar).first { $0.id == id }
    }

    /// The month the id encodes, with all its transactions; empty for an id that encodes no month.
    static func monthTransactions(containing id: Int64, now: Date = .now, calendar: Calendar = .current) -> [Transaction] {
        let yearMonth = id / 100
        guard let month = calendar.date(from: DateComponents(year: Int(yearMonth / 100), month: Int(yearMonth % 100), day: 1))
        else { return [] }
        return transactions(inMonthOf: month, now: now, calendar: calendar)
    }

    /// Both records of the month's transfer, sharing a `transfer_id` derived from the month; none after `now`.
    private static func transfer(
        on date: Date?,
        firstID: Int64,
        within interval: DateInterval,
        now: Date,
        calendar: Calendar
    ) -> [Transaction] {
        guard let date, date < interval.end, date <= now else { return [] }
        let from = accounts[0]
        let to = accounts[1]
        let transferID = UUID(uuidString: String(format: "00000000-0000-4000-8000-%012lld", firstID))
        let offset = LocalOffset(seconds: calendar.timeZone.secondsFromGMT(for: date))

        func record(index: Int64, account: Account, amount: Decimal) -> Transaction {
            Transaction(
                id: firstID + index,
                type: .transfer,
                transactedAt: date,
                localOffset: offset,
                transactionAmount: amount,
                transactionCurrencyCode: account.currencyCode,
                chargedAmount: amount,
                chargedCurrencyCode: account.currencyCode,
                accountID: account.id,
                accountName: account.name,
                group: transferLabel,
                category: transferLabel,
                comment: nil,
                transferID: transferID
            )
        }

        return [
            record(index: transferSentIndex, account: from, amount: -transferSent),
            record(index: transferReceivedIndex, account: to, amount: transferReceived),
        ]
    }
}
