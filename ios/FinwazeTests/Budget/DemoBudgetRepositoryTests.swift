import Foundation
import Testing
@testable import Finwaze

/// The demo Budget agrees with the demo transactions the Transactions list and the Dashboard show (`AUTH-10`).
struct DemoBudgetRepositoryTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Kyiv")!
        return calendar
    }()

    /// 16 September 2026, 18:00 in Kyiv, as in `DemoDashboardRepositoryTests`.
    private var repository: DemoBudgetRepository {
        let now = calendar.date(from: DateComponents(year: 2026, month: 9, day: 16, hour: 18))!
        return DemoBudgetRepository(calendar: calendar, now: { now })
    }

    private let september = YearMonth(year: 2026, month: 9)

    private func query(_ month: YearMonth? = nil, currency: String = "USD", group: Int64? = nil) -> BudgetQuery {
        BudgetQuery(month: month ?? september, currencyCode: currency, groupID: group)
    }

    @Test func groupsSetThePlanAgainstTheSpending() async throws {
        let budgets = try await repository.budgets(query())

        // Up to the 16th: Rent 1 200; Groceries 85 + 65 and Restaurants 45; Taxi 15; Subscriptions 20 without a plan.
        #expect(budgets == [
            BudgetItem(id: 4, name: "Housing", planned: 1200, spent: 1200, categoriesCount: 1, isUnplanned: false),
            BudgetItem(id: 1, name: "Food", planned: 250, spent: 195, categoriesCount: 2, isUnplanned: false),
            BudgetItem(id: 2, name: "Transport", planned: 100, spent: 15, categoriesCount: 2, isUnplanned: false),
            BudgetItem(id: 3, name: "Entertainment", planned: 0, spent: 20, categoriesCount: 1, isUnplanned: true),
        ])
        #expect(budgets.map(\.status) == [.attention, .onTrack, .onTrack, .overBudget])
    }

    /// The same 1 430 of expenses the Dashboard shows for the month.
    @Test func totalsMatchTheDashboard() async throws {
        let totals = try await repository.totals(query())
        let dashboard = try await DemoDashboardRepository(calendar: calendar, now: repository.now)
            .totals(currencyCode: "USD")

        #expect(totals == BudgetTotals(planned: 1550, spent: 1430))
        #expect(totals.spent == dashboard.monthlyExpense)
    }

    @Test func groupShowsItsCategories() async throws {
        let budgets = try await repository.budgets(query(group: 1))
        let totals = try await repository.totals(query(group: 1))

        #expect(budgets == [
            BudgetItem(id: 1, name: "Groceries", planned: 250, spent: 150, categoriesCount: nil, isUnplanned: false),
            BudgetItem(id: 2, name: "Restaurants", planned: 0, spent: 45, categoriesCount: nil, isUnplanned: true),
        ])
        #expect(totals == BudgetTotals(planned: 250, spent: 195))
    }

    @Test func mostExpensesCompareWithLastMonth() async throws {
        let expenses = try await repository.expenses(query())

        // August in full: Rent 1 200; Groceries 205 + Restaurants 85; Cinema 30 + Subscriptions 20; Taxi 33 + bus 5.
        #expect(expenses == [
            MonthlyExpense(id: 4, name: "Housing", amount: 1200, previousAmount: 1200),
            MonthlyExpense(id: 1, name: "Food", amount: 195, previousAmount: 290),
            MonthlyExpense(id: 3, name: "Entertainment", amount: 20, previousAmount: 50),
            MonthlyExpense(id: 2, name: "Transport", amount: 15, previousAmount: 38),
        ])
    }

    @Test func groupExpensesAreByCategory() async throws {
        let expenses = try await repository.expenses(query(group: 1))

        #expect(expenses == [
            MonthlyExpense(id: 1, name: "Groceries", amount: 150, previousAmount: 205),
            MonthlyExpense(id: 2, name: "Restaurants", amount: 45, previousAmount: 85),
        ])
    }

    /// Demo expenses are in USD: another currency has neither a plan nor spending (`BUD-02`).
    @Test func otherCurrencyIsEmpty() async throws {
        #expect(try await repository.budgets(query(currency: "EUR")).isEmpty)
        #expect(try await repository.totals(query(currency: "EUR")) == .zero)
        #expect(try await repository.expenses(query(currency: "EUR")).isEmpty)
    }

    @Test func laterMonthIsEmpty() async throws {
        let october = YearMonth(year: 2026, month: 10)

        #expect(try await repository.budgets(query(october)).isEmpty)
        #expect(try await repository.totals(query(october)) == .zero)
    }
}
