import Foundation
import Testing
@testable import Finwaze

/// The demo Dashboard agrees with the demo transactions the Transactions list shows (`AUTH-10`).
struct DemoDashboardRepositoryTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Kyiv")!
        return calendar
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 18) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    /// 16 September 2026, 18:00 in Kyiv, as in `DemoTransactionsRepositoryTests`.
    private func repository(now: Date? = nil) -> DemoDashboardRepository {
        let now = now ?? date(2026, 9, 16)
        return DemoDashboardRepository(calendar: calendar, now: { now })
    }

    @Test func totalsInUSDFollowTheDemoTransactions() async throws {
        let totals = try await repository().totals(currencyCode: "USD")

        // Up to the 16th: the 3 200 paycheck and 1 430 of expenses; the transfer's −100 is not an expense.
        #expect(totals.monthlyIncome == 3200)
        #expect(totals.monthlyExpense == 1430)
        // The whole of August.
        #expect(totals.previousMonthlyIncome == 3200)
        #expect(totals.previousMonthlyExpense == 1578)
        // Main Card 3 200 + the Emergency Fund goal 5 800; a month ago, without this month's +3 200 − 1 430 − 100.
        #expect(totals.totalBalance == 9000)
        #expect(totals.previousTotalBalance == 7330)
    }

    /// Cash in UAH only receives the transfer: the balance moves, income and expenses stay at zero (`GEN-02`).
    @Test func transferMovesTheBalanceButIsNotIncome() async throws {
        let totals = try await repository().totals(currencyCode: "UAH")

        #expect(totals.monthlyIncome == 0)
        #expect(totals.monthlyExpense == 0)
        #expect(totals.totalBalance == 18500)
        #expect(totals.previousTotalBalance == 14350)
    }

    @Test func cashFlowCoversTwelveMonthsOfDemoTransactions() async throws {
        let months = try await repository().monthlyCashFlow(currencyCode: "USD", months: 12)

        #expect(months.count == 12)
        #expect(months.first?.month == date(2025, 10, 1, hour: 0))
        #expect(months.last == MonthlyCashFlow(month: date(2026, 9, 1, hour: 0), income: 3200, expense: 1430))
        #expect(months[10] == MonthlyCashFlow(month: date(2026, 8, 1, hour: 0), income: 3200, expense: 1578))
    }

    @Test func currencyWithoutTransactionsHasAnEmptyCashFlow() async throws {
        let months = try await repository().monthlyCashFlow(currencyCode: "EUR", months: 12)

        #expect(months.count == 12)
        #expect(months.allSatisfy { $0.income == 0 && $0.expense == 0 })
    }

    @Test func budgetsAreInUSDOnly() async throws {
        #expect(try await repository().currentMonthBudgets(currencyCode: "USD") == DemoData.budgets)
        #expect(try await repository().currentMonthBudgets(currencyCode: "EUR").isEmpty)
    }

    @Test func recentTransactionsAreTheNewestOfTheMonth() async throws {
        let transactions = try await repository().recentTransactions(limit: 3)

        // The 15th's groceries, then both records of the 14th's transfer.
        #expect(transactions.map(\.type) == [.expense, .transfer, .transfer])
        #expect(transactions.first?.transactionAmount == -65)
    }

    @Test func earlyInTheMonthRecentTransactionsReachIntoLastMonth() async throws {
        let transactions = try await repository(now: date(2026, 9, 1)).recentTransactions(limit: 3)

        #expect(transactions.count == 3)
        #expect(transactions.first?.type == .income)
        #expect(calendar.component(.month, from: transactions[1].transactedAt) == 8)
    }

    @Test func goalsAreTheWebsDemoGoals() async throws {
        let goals = try await repository().recentGoals(limit: 3)

        #expect(goals.map(\.name) == ["Emergency Fund", "Vacation"])
        #expect(goals.map(\.progressPercent) == [58, 42])
        #expect(goals.allSatisfy { $0.targetDate > date(2026, 9, 16) })
    }
}
