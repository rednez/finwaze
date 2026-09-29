import Foundation
import Testing
@testable import Finwaze

struct DemoTransfersRepositoryTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Kyiv")!
        return calendar
    }()

    /// 16 September 2026, 18:00 in Kyiv.
    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: 16, hour: 18))!
    }

    private func august() async throws -> [Transaction] {
        let now = now
        let month = YearMonth(year: 2026, month: 8)
        return try await DemoTransactionsRepository(calendar: calendar, now: { now })
            .transactions(matching: TransactionQuery(month: month, type: .transfer, categoryIDs: nil, currencyCode: nil, accountID: nil))
    }

    private func repository() -> DemoTransfersRepository {
        let now = now
        return DemoTransfersRepository(calendar: calendar, now: { now })
    }

    @Test func findsTheTransferFromEitherRecord() async throws {
        let records = try await august()

        for record in records {
            let transfer = try #require(try await repository().transfer(transactionID: record.id))
            #expect(transfer.sent.accountName == "Main Card")
            #expect(transfer.sentAmount == 100)
            #expect(transfer.sent.transactionCurrencyCode == "USD")
            #expect(transfer.received.accountName == "Cash")
            #expect(transfer.receivedAmount == 4150)
            #expect(transfer.received.transactionCurrencyCode == "UAH")
        }
    }

    @Test func noTransferForAnExpenseOrUnknownID() async throws {
        #expect(try await repository().transfer(transactionID: 20260800) == nil)
        #expect(try await repository().transfer(transactionID: 999_999) == nil)
    }

    @Test func makingAndDeletingChangeNothing() async throws {
        let repository = repository()
        let record = try #require(try await august().first)
        let before = try await repository.transfer(transactionID: record.id)

        try await repository.make(
            NewTransfer(
                fromAccountID: 1, toAccountID: 2, fromAmount: 5, toAmount: 200,
                transactedAt: now, localOffset: LocalOffset(seconds: 10_800)
            )
        )
        try await repository.delete(transferID: try #require(before?.id))

        #expect(try await repository.transfer(transactionID: record.id) == before)
        #expect(try await august().count == 2)
    }
}
