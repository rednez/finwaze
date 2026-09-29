import Foundation

/// Demo-mode Wallet: balances from `DemoData`, never from the network (`AUTH-10`). The widgets are worked out from the
/// same demo transactions the Transactions list shows, so the two agree — unlike the web demo's fixed numbers.
nonisolated struct DemoWalletRepository: WalletRepository {
    var calendar: Calendar = .current
    var now: @Sendable () -> Date = { .now }

    func accounts() async throws -> [WalletAccount] {
        WalletMapper.sortedByName(DemoData.walletAccounts)
    }

    func accountDetails(id: Int64) async throws -> AccountDetails? {
        guard
            let account = DemoData.walletAccounts.first(where: { $0.id == id }),
            let currency = DemoData.currencies.first(where: { $0.code == account.currencyCode })
        else { return nil }
        return AccountDetails(
            id: account.id,
            name: account.name,
            currencyID: currency.id,
            currencyCode: currency.code,
            balance: account.balance,
            canDelete: !DemoData.accountIDsWithTransactions.contains(account.id)
        )
    }

    /// A no-op, like on the web: nothing is stored, so the demo never changes.
    func updateAccount(id: Int64, _ update: AccountUpdate) async throws -> Bool {
        true
    }

    /// A no-op, like `updateAccount`.
    func adjustBalance(_ adjustment: BalanceAdjustment) async throws {}

    /// A no-op, like `updateAccount`: the "deleted" account stays in place.
    func deleteAccount(id: Int64) async throws {}

    /// Every day of the month, from the month's incomes and expenses in the purchase currency (`ACC-03`, `GEN-02`).
    func dailyCashFlow(month: YearMonth, currencyCode: String) async throws -> [DailyCashFlow] {
        guard
            let start = month.start(in: calendar),
            let days = calendar.range(of: .day, in: .month, for: start)
        else { return [] }
        let byDay = Dictionary(grouping: incomesAndExpenses(inMonthOf: start, currencyCode: currencyCode)) {
            calendar.startOfDay(for: $0.transactedAt)
        }
        return days.compactMap { day in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: start) else { return nil }
            let transactions = byDay[date] ?? []
            return DailyCashFlow(day: date, income: transactions.income(\.transactionAmount), expense: transactions.expense(\.transactionAmount))
        }
    }

    /// This month's newest in the purchase currency, topped up from last month early in the month; transfers too,
    /// like the server.
    func recentTransactions(currencyCode: String, limit: Int) async throws -> [Transaction] {
        let now = now()
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        let recent = DemoData.transactions(inMonthOf: now, now: now, calendar: calendar)
            + DemoData.transactions(inMonthOf: lastMonth, now: now, calendar: calendar)
        return Array(recent.filter { $0.transactionCurrencyCode == currencyCode }.prefix(limit))
    }

    /// The month's incomes and expenses in the purchase currency by group (`ACC-05`).
    func amountsByGroup(month: YearMonth, currencyCode: String) async throws -> [GroupAmounts] {
        guard let start = month.start(in: calendar) else { return [] }
        let byGroup = Dictionary(grouping: incomesAndExpenses(inMonthOf: start, currencyCode: currencyCode), by: \.group.id)
        return byGroup.values.compactMap { transactions in
            guard let group = transactions.first?.group else { return nil }
            return GroupAmounts(
                id: group.id,
                name: group.name,
                income: transactions.income(\.transactionAmount),
                expense: transactions.expense(\.transactionAmount)
            )
        }
        .sorted { $0.id < $1.id }
    }

    /// The month's incomes and expenses in the purchase currency; transfers never count (`GEN-02`).
    private func incomesAndExpenses(inMonthOf month: Date, currencyCode: String) -> [Transaction] {
        DemoData.transactions(inMonthOf: month, now: now(), calendar: calendar)
            .filter { $0.transactionCurrencyCode == currencyCode && $0.isCounted }
    }
}
