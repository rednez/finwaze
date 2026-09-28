import Foundation
import Testing
@testable import Finwaze

/// The demo Wallet's widgets agree with the demo transactions the Transactions list shows (`AUTH-10`).
struct DemoWalletRepositoryTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Kyiv")!
        return calendar
    }()

    private let september = YearMonth(year: 2026, month: 9)

    /// 16 September 2026, 18:00 in Kyiv, as in `DemoDashboardRepositoryTests`.
    private var repository: DemoWalletRepository {
        let now = calendar.date(from: DateComponents(year: 2026, month: 9, day: 16, hour: 18))!
        return DemoWalletRepository(calendar: calendar, now: { now })
    }

    private func day(_ days: [DailyCashFlow], _ number: Int) -> DailyCashFlow? {
        days.first { calendar.component(.day, from: $0.day) == number }
    }

    @Test func dailyCashFlowCoversEveryDayOfTheMonth() async throws {
        let days = try await repository.dailyCashFlow(month: september, currencyCode: "USD")

        #expect(days.count == 30)
        #expect(day(days, 1)?.income == 3200)
        #expect(day(days, 3)?.expense == 1200)
        // The transfer on the 14th is neither income nor expense (`GEN-02`); the 20th is still to come.
        #expect(day(days, 14)?.expense == 0)
        #expect(day(days, 20)?.expense == 0)
        #expect(days.reduce(0) { $0 + $1.expense } == 1430)
    }

    /// Cash in UAH only receives the transfer.
    @Test func transfersAreNotInTheDailyCashFlow() async throws {
        let days = try await repository.dailyCashFlow(month: september, currencyCode: "UAH")

        #expect(days.count == 30)
        #expect(days.allSatisfy { $0.income == 0 && $0.expense == 0 })
    }

    @Test func recentTransactionsAreTheNewestInTheCurrency() async throws {
        let usd = try await repository.recentTransactions(currencyCode: "USD", limit: 3)
        let uah = try await repository.recentTransactions(currencyCode: "UAH", limit: 3)
        let eur = try await repository.recentTransactions(currencyCode: "EUR", limit: 3)

        // Groceries on the 15th, the transfer sent on the 14th, subscriptions on the 12th.
        #expect(usd.map(\.id) == [20_260_906, 20_260_950, 20_260_905])
        // This month's and last month's transfers received.
        #expect(uah.map(\.id) == [20_260_951, 20_260_851])
        #expect(eur.isEmpty)
    }

    @Test func amountsByGroupFollowTheDemoTransactions() async throws {
        let groups = try await repository.amountsByGroup(month: september, currencyCode: "USD")

        #expect(groups == [
            GroupAmounts(id: 1, name: "Food", income: 0, expense: 195),
            GroupAmounts(id: 2, name: "Transport", income: 0, expense: 15),
            GroupAmounts(id: 3, name: "Entertainment", income: 0, expense: 20),
            GroupAmounts(id: 4, name: "Housing", income: 0, expense: 1200),
            GroupAmounts(id: 5, name: "Salary", income: 3200, expense: 0),
        ])
    }

    @Test func noTransactionsInTheCurrencyIsEmpty() async throws {
        #expect(try await repository.amountsByGroup(month: september, currencyCode: "EUR").isEmpty)
    }
}
