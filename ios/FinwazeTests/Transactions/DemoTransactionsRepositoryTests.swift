import Foundation
import Testing
@testable import Finwaze

struct DemoTransactionsRepositoryTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Kyiv")!
        return calendar
    }()

    /// 16 September 2026, 18:00 in Kyiv.
    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: 16, hour: 18))!
    }

    private func month(_ year: Int, _ month: Int) -> YearMonth {
        YearMonth(year: year, month: month)
    }

    private func repository() -> DemoTransactionsRepository {
        let now = now
        return DemoTransactionsRepository(calendar: calendar, now: { now })
    }

    private func query(month: YearMonth, type: TransactionType? = nil, categoryIDs: [Int64]? = nil) -> TransactionQuery {
        TransactionQuery(month: month, type: type, categoryIDs: categoryIDs, currencyCode: nil, accountID: nil)
    }

    @Test func pastMonthHasTheWholeTemplateAndTheTransferNewestFirst() async throws {
        let transactions = try await repository().transactions(matching: query(month: month(2026, 2)))

        #expect(transactions.count == 14)
        #expect(Set(transactions.map(\.id)).count == 14)
        #expect(transactions.map(\.transactedAt) == transactions.map(\.transactedAt).sorted(by: >))
        #expect(transactions.allSatisfy { calendar.component(.month, from: $0.transactedAt) == 2 })
    }

    @Test func currentMonthStopsAtNow() async throws {
        let transactions = try await repository().transactions(matching: query(month: month(2026, 9)))

        // 7 template days up to the 16th, plus the transfer on the 14th (2 records).
        #expect(transactions.count == 9)
        #expect(transactions.allSatisfy { $0.transactedAt <= now })
    }

    @Test func laterMonthIsEmpty() async throws {
        #expect(try await repository().transactions(matching: query(month: month(2026, 10))).isEmpty)
    }

    @Test func monthHasOneTransferBetweenTwoAccounts() async throws {
        let transfers = try await repository().transactions(matching: query(month: month(2026, 8), type: .transfer))

        #expect(transfers.count == 2)
        #expect(Set(transfers.compactMap(\.transferID)).count == 1)
        #expect(transfers.map(\.transactionAmount).sorted() == [-100, 4150])
        #expect(Set(transfers.map(\.accountID)) == [1, 2])
    }

    @Test func expensesAreNegativeAndIncomesPositive() async throws {
        let transactions = try await repository().transactions(matching: query(month: month(2026, 8)))

        #expect(transactions.filter { $0.type == .expense }.allSatisfy { $0.transactionAmount < 0 })
        #expect(transactions.filter { $0.type == .income }.allSatisfy { $0.transactionAmount > 0 })
    }

    @Test func appliesFilters() async throws {
        let incomes = try await repository().transactions(matching: query(month: month(2026, 8), type: .income))
        let groceries = try await repository().transactions(matching: query(month: month(2026, 8), categoryIDs: [1]))

        #expect(incomes.map(\.category.name) == ["Monthly Paycheck"])
        #expect(groceries.count == 3)
        #expect(groceries.allSatisfy { $0.category.id == 1 })
    }

    @Test func creatingChangesNothing() async throws {
        let repository = repository()
        let before = try await repository.transactions(matching: query(month: month(2026, 9)))

        try await repository.create(
            NewTransaction(
                type: .expense, transactedAt: now, localOffset: LocalOffset(seconds: 10_800), accountID: 1,
                categoryID: 1, transactionAmount: 5, transactionCurrencyID: 1, chargedAmount: 5, comment: nil
            )
        )

        #expect(try await repository.transactions(matching: query(month: month(2026, 9))) == before)
    }

    // MARK: Details, update, delete (TX-06, TX-40, TX-41)

    @Test func findsATransactionByID() async throws {
        let repository = repository()
        let august = try await repository.transactions(matching: query(month: month(2026, 8)))
        let expected = try #require(august.first)

        #expect(try await repository.transaction(id: expected.id) == expected)
    }

    @Test func answersNilForAnUnknownID() async throws {
        #expect(try await repository().transaction(id: 999_999) == nil)
    }

    @Test func updatingAndDeletingChangeNothing() async throws {
        let repository = repository()
        let august = try await repository.transactions(matching: query(month: month(2026, 8)))
        let target = try #require(august.first)

        let update = TransactionUpdate(
            transactedAt: now, localOffset: LocalOffset(seconds: 10_800), accountID: 1, categoryID: 1,
            transactionAmount: 999, transactionCurrencyID: 1, chargedAmount: 999, comment: "changed"
        )
        #expect(try await repository.update(id: target.id, update))
        #expect(try await repository.transaction(id: target.id) == target)

        try await repository.delete(id: target.id)
        #expect(try await repository.transaction(id: target.id) == target)
    }
}
