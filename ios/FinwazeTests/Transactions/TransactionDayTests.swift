import Foundation
import Testing
@testable import Finwaze

struct TransactionDayTests {
    private func transaction(
        id: Int64,
        at iso: String,
        offset: Int = 10_800,
        type: TransactionType = .expense,
        amount: Decimal = -10,
        currency: String = "UAH"
    ) -> Transaction {
        let base = Transaction.fixture(id: id, type: type, amount: amount, currencyCode: currency)
        return Transaction(
            id: base.id, type: base.type,
            transactedAt: Date(timestamptz: iso)!,
            localOffset: LocalOffset(seconds: offset),
            transactionAmount: base.transactionAmount, transactionCurrencyCode: base.transactionCurrencyCode,
            chargedAmount: base.chargedAmount, chargedCurrencyCode: base.chargedCurrencyCode,
            accountID: base.accountID, accountName: base.accountName, group: base.group, category: base.category,
            comment: nil, transferID: nil
        )
    }

    @Test func groupsByLocalDayKeepingOrder() {
        let days = TransactionDay.group([
            transaction(id: 3, at: "2026-09-27T18:00:00Z"),
            transaction(id: 2, at: "2026-09-27T06:00:00Z"),
            transaction(id: 1, at: "2026-09-25T10:00:00Z"),
        ])

        #expect(days.map(\.id) == ["2026-09-27", "2026-09-25"])
        #expect(days.map { $0.transactions.map(\.id) } == [[3, 2], [1]])
    }

    /// `GEN-12`: 00:30 local time on the 1st belongs to the 1st, although it is still the 30th in UTC.
    @Test func usesTheOffsetOfEachTransaction() {
        let days = TransactionDay.group([
            transaction(id: 2, at: "2026-09-30T21:30:00Z", offset: 10_800),
            transaction(id: 1, at: "2026-09-30T20:30:00Z", offset: 0),
        ])

        #expect(days.map(\.id) == ["2026-10-01", "2026-09-30"])
    }

    @Test func emptyListHasNoDays() {
        #expect(TransactionDay.group([]).isEmpty)
    }

    @Test func totalsAddIncomeAndExpensesOnly() throws {
        let totals = try #require(TransactionTotals.of([
            transaction(id: 1, at: "2026-09-27T10:00:00Z", type: .income, amount: Decimal(string: "0.1")!),
            transaction(id: 2, at: "2026-09-27T10:00:00Z", type: .income, amount: Decimal(string: "0.2")!),
            transaction(id: 3, at: "2026-09-27T10:00:00Z", amount: -5),
            transaction(id: 4, at: "2026-09-27T10:00:00Z", type: .transfer, amount: -100),
        ]))

        #expect(totals.income == Decimal(string: "0.3")!)
        #expect(totals.expenses == -5)
        #expect(totals.net == Decimal(string: "-4.7")!)
        #expect(totals.currencyCode == "UAH")
    }

    /// Amounts in different currencies are never added up.
    @Test func noTotalsAcrossCurrencies() {
        #expect(TransactionTotals.of([
            transaction(id: 1, at: "2026-09-27T10:00:00Z", currency: "UAH"),
            transaction(id: 2, at: "2026-09-27T10:00:00Z", currency: "EUR"),
        ]) == nil)
    }

    @Test func transfersAloneHaveNoTotals() {
        #expect(TransactionTotals.of([transaction(id: 1, at: "2026-09-27T10:00:00Z", type: .transfer)]) == nil)
        #expect(TransactionTotals.of([]) == nil)
    }
}
