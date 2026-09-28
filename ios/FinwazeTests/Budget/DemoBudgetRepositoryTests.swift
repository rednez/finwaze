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

    // MARK: Plan (BUD-20…26)

    private func line(
        _ categoryID: Int64,
        _ category: String,
        _ groupID: Int64,
        _ group: String,
        planned: Decimal,
        previousPlanned: Decimal,
        spent: Decimal,
        previousSpent: Decimal
    ) -> BudgetPlanLine {
        BudgetPlanLine(
            categoryID: categoryID,
            categoryName: category,
            groupID: groupID,
            groupName: group,
            planned: planned,
            stats: BudgetPlanStats(previousPlanned: previousPlanned, spent: spent, previousSpent: previousSpent)
        )
    }

    @Test func septemberPlanHasReferenceFigures() async throws {
        let plan = try await repository.plan(month: september, currencyCode: "USD")

        #expect(plan == [
            line(7, "Rent", 4, "Housing", planned: 1200, previousPlanned: 1200, spent: 1200, previousSpent: 1200),
            line(1, "Groceries", 1, "Food", planned: 250, previousPlanned: 250, spent: 150, previousSpent: 205),
            line(3, "Taxi", 2, "Transport", planned: 60, previousPlanned: 60, spent: 15, previousSpent: 33),
            line(4, "Public Transport", 2, "Transport", planned: 40, previousPlanned: 40, spent: 0, previousSpent: 5),
        ])
    }

    @Test func laterMonthHasNoPlan() async throws {
        #expect(try await repository.plan(month: YearMonth(year: 2026, month: 10), currencyCode: "USD").isEmpty)
    }

    /// October from September: the plan where there is one, September's spending for Restaurants and Subscriptions.
    @Test func generatesFromLastMonthsPlanThenSpending() async throws {
        let plan = try await repository.generatedPlan(month: YearMonth(year: 2026, month: 10), currencyCode: "USD")

        #expect(plan.map(\.categoryName) == ["Rent", "Groceries", "Taxi", "Restaurants", "Public Transport",
                                             "Subscriptions"])
        #expect(plan.map(\.planned) == [1200, 250, 60, 45, 40, 20])
        #expect(plan[3] == line(2, "Restaurants", 1, "Food", planned: 45, previousPlanned: 0, spent: 0,
                                previousSpent: 45))
    }

    @Test func generatesNothingWithoutPlanOrSpending() async throws {
        #expect(try await repository.generatedPlan(month: YearMonth(year: 2026, month: 12), currencyCode: "USD")
            .isEmpty)
        #expect(try await repository.generatedPlan(month: september, currencyCode: "EUR").isEmpty)
    }

    @Test func categoryStatsComeFromTheDemoExpenses() async throws {
        let stats = try await repository.categoryStats(month: september, currencyCode: "USD", categoryID: 2)

        #expect(stats == BudgetPlanStats(previousPlanned: 0, spent: 45, previousSpent: 85))
    }

    /// Saving succeeds but changes nothing (`AUTH-10`).
    @Test func savingKeepsThePlan() async throws {
        try await repository.savePlan(month: september, currencyCode: "USD", amounts: [5: 100])

        #expect(try await repository.plan(month: september, currencyCode: "USD").count == 4)
    }
}
