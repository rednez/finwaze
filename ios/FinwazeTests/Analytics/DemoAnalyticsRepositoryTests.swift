import Foundation
import Testing
@testable import Finwaze

/// The demo Analytics agrees with the demo transactions and the demo Dashboard (`AUTH-10`).
struct DemoAnalyticsRepositoryTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Kyiv")!
        return calendar
    }()

    private let september = YearMonth(year: 2026, month: 9)

    /// 16 September 2026, 18:00 in Kyiv, as in `DemoDashboardRepositoryTests`.
    private var repository: DemoAnalyticsRepository {
        let now = calendar.date(from: DateComponents(year: 2026, month: 9, day: 16, hour: 18))!
        return DemoAnalyticsRepository(calendar: calendar, now: { now })
    }

    private func query(_ currencyCode: String = "USD", month: YearMonth? = nil, accounts: Set<Int64> = []) -> AnalyticsQuery {
        AnalyticsQuery(month: month ?? september, currencyCode: currencyCode, accountIDs: accounts)
    }

    // MARK: Summary (ANL-02)

    @Test func summaryFollowsTheDemoTransactionsAndTheDashboard() async throws {
        let summary = try await repository.summary(query())
        let dashboard = try await DemoDashboardRepository(calendar: calendar, now: repository.now).totals(currencyCode: "USD")

        // Up to the 16th: the 3 200 paycheck and six expenses; the transfer's −100 is not an expense (`GEN-02`).
        #expect(summary.monthlyIncome == 3200)
        #expect(summary.monthlyExpense == 1430)
        #expect(summary.previousMonthlyIncome == 3200)
        #expect(summary.previousMonthlyExpense == 1578)
        #expect(summary.incomeTransactionCount == 1)
        #expect(summary.expenseTransactionCount == 6)
        #expect(summary.incomeGroupsCount == 1)
        #expect(summary.expenseGroupsCount == 4) // Housing, Food, Transport, Entertainment
        // The same as the Dashboard: the Main Card and the Emergency Fund goal.
        #expect(summary.totalBalance == dashboard.totalBalance)
        #expect(summary.previousTotalBalance == dashboard.previousTotalBalance)
    }

    /// Last month's closing balance is today's less this month's records, the transfer included (`GEN-03`).
    @Test func lastMonthsBalanceIsTodaysLessThisMonthsRecords() async throws {
        let summary = try await repository.summary(query(accounts: [1]))

        #expect(summary.totalBalance == 3200) // the Main Card alone, no goal
        #expect(summary.previousTotalBalance == 1530) // 3 200 − (3 200 − 1 430 − 100)
    }

    @Test func transferMovesTheBalanceButIsNotIncome() async throws {
        let summary = try await repository.summary(query("UAH"))

        #expect(summary.monthlyIncome == 0)
        #expect(summary.monthlyExpense == 0)
        #expect(summary.incomeTransactionCount == 0)
        #expect(summary.totalBalance == 18500)
        #expect(summary.previousTotalBalance == 14350) // without the transfer's 4 150
    }

    @Test func anAccountFilterKeepsOnlyItsRecords() async throws {
        // Cash holds no dollars: nothing of the Main Card's is counted.
        let summary = try await repository.summary(query(accounts: [2]))
        let groups = try await repository.amountsByGroup(query(accounts: [2]))

        #expect(summary == .zero)
        #expect(groups.isEmpty)
    }

    @Test func currencyWithoutAccountsIsZero() async throws {
        let summary = try await repository.summary(query("CZK"))
        let days = try await repository.dailyOverview(query("CZK"))

        #expect(summary == .zero)
        #expect(days.count == 30)
        #expect(days.allSatisfy { $0.income == 0 && $0.expense == 0 && $0.balance == 0 })
    }

    // MARK: Daily overview (ANL-03)

    @Test func dailyOverviewCoversEveryDayWithTheBalanceAtItsEnd() async throws {
        let days = try await repository.dailyOverview(query())

        #expect(days.map(\.dayOfMonth) == Array(1...30))
        #expect(days[0].income == 3200)
        #expect(days[2].expense == 1200)
        // The transfer on the 14th moves the balance but is not an expense.
        #expect(days[13].expense == 0)
        #expect(days[12].balance - days[13].balance == 100)
        // After the last record the balance stays where it is, up to the month's end.
        #expect(days[15].balance == 9000)
        #expect(days[29].balance == 9000)
    }

    @Test func previousMonthEndsAtLastMonthsClosingBalance() async throws {
        let august = try await repository.dailyOverview(query(month: YearMonth(year: 2026, month: 8)))
        let summary = try await repository.summary(query())

        #expect(august.count == 31)
        #expect(august.last?.balance == summary.previousTotalBalance)
    }

    // MARK: Statistics (ANL-05)

    @Test func amountsByGroupLeaveOutTransfers() async throws {
        let groups = try await repository.amountsByGroup(query())

        #expect(groups.map(\.name) == ["Housing", "Food", "Entertainment", "Transport", "Salary"])
        #expect(groups.first == GroupAmounts(id: 4, name: "Housing", income: 0, expense: 1200))
        #expect(groups.last == GroupAmounts(id: 5, name: "Salary", income: 3200, expense: 0))
    }

    // MARK: Budgets vs Expenses (ANL-04)

    @Test func yearHasThePlanUpToNowAndTheExpensesByAccountCurrency() async throws {
        let months = try await repository.yearlyBudgetsVsExpenses(year: 2026, currencyCode: "USD")

        #expect(months.map(\.month) == (1...12).map { YearMonth(year: 2026, month: $0) })
        #expect(months[0] == MonthlyBudgetExpense(month: YearMonth(year: 2026, month: 1), budget: 1550, expense: 1578))
        #expect(months[8] == MonthlyBudgetExpense(month: september, budget: 1550, expense: 1430))
        #expect(months[9] == MonthlyBudgetExpense(month: YearMonth(year: 2026, month: 10), budget: 0, expense: 0))
    }
}
