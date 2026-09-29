import Foundation
import Testing
@testable import Finwaze

/// Mappers and pure logic of the Budget: status, amounts, the month parameter, filters.
@MainActor
struct BudgetDataTests {
    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(type, from: Data(json.utf8))
    }

    // MARK: Status (BUD-03…05)

    @Test(arguments: [
        // "Groceries 4 000 ₴": 500 left is 12.5 % — attention (the document's acceptance criterion).
        (planned: 4000, spent: 3500, status: BudgetStatus.attention),
        // Exactly 20 % left is still on track.
        (planned: 4000, spent: 3200, status: .onTrack),
        (planned: 4000, spent: 0, status: .onTrack),
        // Nothing left is attention, not over budget.
        (planned: 4000, spent: 4000, status: .attention),
        (planned: 4000, spent: 4100, status: .overBudget),
        // Spending without a plan (`BUD-05`).
        (planned: 0, spent: 20, status: .overBudget),
    ] as [(planned: Decimal, spent: Decimal, status: BudgetStatus)])
    func status(planned: Decimal, spent: Decimal, status: BudgetStatus) {
        #expect(BudgetStatus(planned: planned, spent: spent) == status)
    }

    @Test func remainingMayBeNegative() {
        let item = BudgetItem(id: 1, name: "Groceries", planned: 4000, spent: 4100, categoriesCount: 1, isUnplanned: false)

        #expect(item.remaining == -100)
    }

    @Test func noPlanLeavesSpentAsOverspent() {
        let item = BudgetItem(id: 1, name: "Cinema", planned: 0, spent: 30, categoriesCount: nil, isUnplanned: true)

        #expect(item.remaining == -30)
    }

    // MARK: Mapper

    @Test func groupSpendingBecomesPositive() throws {
        let dtos = try decode([GroupMonthlyBudgetDto].self, """
            [{"group_id": 4, "group_name": "Housing", "planned_amount": 1200, "spent_amount": -1200.5,
              "categories_count": 1, "is_unplanned": false},
             {"group_id": 3, "group_name": "Entertainment", "planned_amount": 0, "spent_amount": -20,
              "categories_count": 1, "is_unplanned": true}]
            """)

        let items = dtos.map(BudgetMapper.toItem)

        #expect(items == [
            BudgetItem(id: 4, name: "Housing", planned: 1200, spent: Decimal(string: "1200.5")!, categoriesCount: 1,
                       isUnplanned: false),
            BudgetItem(id: 3, name: "Entertainment", planned: 0, spent: 20, categoriesCount: 1, isUnplanned: true),
        ])
    }

    @Test func categorySpendingBecomesPositive() throws {
        let dto = try decode([CategoryMonthlyBudgetDto].self, """
            [{"category_id": 1, "category_name": "Groceries", "planned_amount": 250, "spent_amount": -150,
              "is_unplanned": false}]
            """)[0]

        #expect(BudgetMapper.toItem(dto) == BudgetItem(
            id: 1, name: "Groceries", planned: 250, spent: 150, categoriesCount: nil, isUnplanned: false
        ))
    }

    /// Unlike the lists, the totals come positive already; both end up the same.
    @Test func totalsStayPositiveAndNullIsZero() throws {
        let dtos = try decode([MonthlyBudgetTotalsDto].self, """
            [{"planned_amount": 1550, "spent_amount": 1430.25}]
            """)
        let empty = try decode([MonthlyBudgetTotalsDto].self, """
            [{"planned_amount": null, "spent_amount": null}]
            """)

        #expect(BudgetMapper.toTotals(dtos.first) == BudgetTotals(planned: 1550, spent: Decimal(string: "1430.25")!))
        #expect(BudgetMapper.toTotals(empty.first) == .zero)
        #expect(BudgetMapper.toTotals(nil) == .zero)
    }

    @Test func expensesKeepBothMonths() throws {
        let group = try decode([GroupMonthlyExpenseDto].self, """
            [{"group_id": 1, "group_name": "Food", "selected_month_amount": 195, "previous_month_amount": 290}]
            """)[0]
        let category = try decode([CategoryMonthlyExpenseDto].self, """
            [{"category_id": 2, "category_name": "Restaurants", "selected_month_amount": 45,
              "previous_month_amount": null}]
            """)[0]

        #expect(BudgetMapper.toExpense(group) == MonthlyExpense(id: 1, name: "Food", amount: 195, previousAmount: 290))
        #expect(BudgetMapper.toExpense(category) == MonthlyExpense(
            id: 2, name: "Restaurants", amount: 45, previousAmount: 0
        ))
    }

    /// Growth of spending is bad (`BUD-14`).
    @Test func spendingMoreThanLastMonthIsBad() {
        let trend = MonthlyExpense(id: 1, name: "Food", amount: 300, previousAmount: 200).trend

        #expect(trend.direction == .up)
        #expect(trend.assessment == .bad)
        #expect(MonthlyExpense(id: 1, name: "Food", amount: 100, previousAmount: 200).trend.assessment == .good)
        #expect(MonthlyExpense(id: 1, name: "Food", amount: 100, previousAmount: 0).trend.assessment == .neutral)
    }

    // MARK: Month (GEN-12, GEN-14)

    /// The month is the user's calendar month: the parameter is its first day wherever the device is.
    @Test(arguments: ["America/New_York", "Europe/Kyiv", "UTC"])
    func monthParameterIsTheLocalMonth(timeZone: String) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timeZone)!
        // 1 October 2026, 00:30 local time — already October here, still September in UTC for Kyiv.
        let now = calendar.date(from: DateComponents(year: 2026, month: 10, day: 1, hour: 0, minute: 30))!

        let filter = BudgetFilter(now: now, calendar: calendar)

        #expect(filter.month == YearMonth(year: 2026, month: 10))
        #expect(filter.month.firstDayParameter == "2026-10-01")
    }

    @Test func shiftingCrossesTheYear() {
        let filter = BudgetFilter(now: .now)
        let start = filter.month

        filter.shiftMonth(by: -(start.month))

        #expect(filter.month == YearMonth(year: start.year - 1, month: 12))
        #expect(filter.month.firstDayParameter == "\(start.year - 1)-12-01")
    }

    // MARK: Filters (BUD-11)

    @Test func statusAndGroupsNarrowTheCards() {
        let filter = BudgetFilter()
        let food = BudgetItem(id: 1, name: "Food", planned: 250, spent: 195, categoriesCount: 2, isUnplanned: false)
        let housing = BudgetItem(id: 4, name: "Housing", planned: 1200, spent: 1200, categoriesCount: 1,
                                 isUnplanned: false)

        #expect(filter.matches(food) && filter.matches(housing))

        filter.status = .attention
        #expect(!filter.matches(food))
        #expect(filter.matches(housing))

        filter.status = nil
        filter.groupIDs = [1]
        #expect(filter.matches(food))
        #expect(!filter.matches(housing))

        filter.clearGroupFilters()
        #expect(filter.status == nil && filter.groupIDs.isEmpty)
    }
}
