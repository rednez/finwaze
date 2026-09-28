import Foundation
import Testing
@testable import Finwaze

/// Mappers and pure logic of the Dashboard: totals, cash flow months, budget ring, change badges.
struct DashboardDataTests {
    private func calendar(_ identifier: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: identifier)!
        return calendar
    }

    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(type, from: Data(json.utf8))
    }

    /// 16 September 2026, 12:00 UTC.
    private let now = Date(timeIntervalSince1970: 1_789_560_000)

    // MARK: Totals (DASH-02)

    @Test func totalsMakeExpensesPositive() throws {
        let dto = try decode([DashboardTotalsDto].self, """
            [{"total_balance": 27500.5, "monthly_income": 3200, "monthly_expense": -1573.25,
              "previous_total_balance": 25900, "previous_monthly_income": 3200, "previous_monthly_expense": -1820}]
            """).first

        let totals = DashboardMapper.toTotals(dto)

        #expect(totals.totalBalance == Decimal(string: "27500.5"))
        #expect(totals.monthlyExpense == Decimal(string: "1573.25"))
        #expect(totals.previousMonthlyExpense == 1820)
        #expect(totals.previousTotalBalance == 25900)
    }

    @Test func totalsTreatNullAndMissingRowAsZero() throws {
        let dto = try decode([DashboardTotalsDto].self, """
            [{"total_balance": null, "monthly_income": null, "monthly_expense": null,
              "previous_total_balance": null, "previous_monthly_income": null, "previous_monthly_expense": null}]
            """).first

        #expect(DashboardMapper.toTotals(dto) == .zero)
        #expect(DashboardMapper.toTotals(nil) == .zero)
    }

    // MARK: Cash flow (DASH-04)

    private func cashFlowRows(_ rows: String) throws -> [MonthlyCashFlowDto] {
        try decode([MonthlyCashFlowDto].self, rows)
    }

    @Test func cashFlowFillsMissingMonthsWithZeros() throws {
        let rows = try cashFlowRows("""
            [{"month": "2026-07-01T00:00:00+00:00", "total_income": 3200, "total_expense": -1500.5},
             {"month": "2026-09-01T00:00:00+00:00", "total_income": null, "total_expense": -20}]
            """)
        let kyiv = calendar("Europe/Kyiv")

        let months = try DashboardMapper.toCashFlow(rows, months: 12, now: now, calendar: kyiv)

        #expect(months.count == 12)
        #expect(months.first?.month == kyiv.date(from: DateComponents(year: 2025, month: 10, day: 1)))
        #expect(months.last?.month == kyiv.date(from: DateComponents(year: 2026, month: 9, day: 1)))
        #expect(months[9] == MonthlyCashFlow(
            month: kyiv.date(from: DateComponents(year: 2026, month: 7, day: 1))!,
            income: 3200,
            expense: Decimal(string: "1500.5")!
        ))
        #expect(months[10].income == 0 && months[10].expense == 0)
        #expect(months[11].income == 0 && months[11].expense == 20)
    }

    /// The server's month starts at midnight UTC; west of UTC that moment is still the previous month's last day.
    @Test(arguments: ["America/New_York", "Europe/Kyiv", "Asia/Tokyo"])
    func cashFlowKeepsTheServersMonthInAnyTimeZone(_ timeZone: String) throws {
        let rows = try cashFlowRows("""
            [{"month": "2026-09-01T00:00:00+00:00", "total_income": 100, "total_expense": 0}]
            """)
        let device = calendar(timeZone)

        let months = try DashboardMapper.toCashFlow(rows, months: 1, now: now, calendar: device)

        #expect(months.count == 1)
        #expect(device.dateComponents([.year, .month, .day], from: months[0].month)
            == DateComponents(year: 2026, month: 9, day: 1))
        #expect(months[0].income == 100)
    }

    @Test func cashFlowRejectsAnUnreadableMonth() throws {
        let rows = try cashFlowRows(#"[{"month": "September", "total_income": 1, "total_expense": 0}]"#)

        #expect(throws: DashboardMapper.MappingError.invalidMonth("September")) {
            try DashboardMapper.toCashFlow(rows, months: 12, now: now)
        }
    }

    @Test func lastMonthsCrossTheYear() {
        let months = DashboardMapper.lastMonths(3, now: Date(timeIntervalSince1970: 1_767_268_800)) // 1 Jan 2026 12:00 UTC

        #expect(months == [YearMonth(year: 2025, month: 11), YearMonth(year: 2025, month: 12), YearMonth(year: 2026, month: 1)])
    }

    @Test func yearMonthAddsMonths() {
        #expect(YearMonth(year: 2026, month: 1).adding(months: -1) == YearMonth(year: 2025, month: 12))
        #expect(YearMonth(year: 2026, month: 12).adding(months: 1) == YearMonth(year: 2027, month: 1))
        #expect(YearMonth(year: 2026, month: 9).adding(months: -11) == YearMonth(year: 2025, month: 10))
    }

    // MARK: Budget ring (DASH-05)

    @Test func budgetIsSortedLargestFirstWithTotal() throws {
        let rows = try decode([CategoryBudgetDto].self, """
            [{"category_name": "Groceries", "total_budget": 250}, {"category_name": "Rent", "total_budget": 1200.5}]
            """)

        let summary = SliceSummary(budgets: rows.map(DashboardMapper.toBudget))

        #expect(summary.slices.map(\.name) == ["Rent", "Groceries"])
        #expect(summary.slices.map(\.id) == [0, 1])
        #expect(summary.total == Decimal(string: "1450.5"))
    }

    @Test func sevenCategoriesAreAllShown() {
        let budgets = (1...7).map { CategoryBudget(name: "C\($0)", amount: Decimal($0)) }

        let summary = SliceSummary(budgets: budgets)

        #expect(summary.slices.count == 7)
        #expect(summary.slices.allSatisfy { !$0.isOther })
    }

    @Test func moreThanSevenCategoriesJoinTheSmallestIntoOther() {
        let budgets = (1...9).map { CategoryBudget(name: "C\($0)", amount: Decimal($0 * 10)) }

        let summary = SliceSummary(budgets: budgets)

        #expect(summary.slices.count == 7)
        #expect(summary.slices.prefix(6).map(\.name) == ["C9", "C8", "C7", "C6", "C5", "C4"])
        #expect(summary.slices.last == ChartSlice(id: 6, name: nil, amount: 60)) // 30 + 20 + 10
        #expect(summary.total == 450)
    }

    @Test func equalAmountsAreOrderedByName() {
        let summary = SliceSummary(budgets: [CategoryBudget(name: "Taxi", amount: 10), CategoryBudget(name: "Bus", amount: 10)])

        #expect(summary.slices.map(\.name) == ["Bus", "Taxi"])
    }

    @Test func noBudgetsIsEmpty() {
        let summary = SliceSummary(budgets: [])

        #expect(summary.slices.isEmpty)
        #expect(summary.total == 0)
    }

    // MARK: Change badge (DASH-03)

    @Test func growthOfIncomeIsGood() {
        let trend = TrendChange(current: 110, previous: 100, growthIsGood: true)

        #expect(trend.ratio == Decimal(string: "0.1"))
        #expect(trend.direction == .up)
        #expect(trend.assessment == .good)
    }

    @Test func growthOfExpensesIsBad() {
        let trend = TrendChange(current: 2000, previous: 1600, growthIsGood: false)

        #expect(trend.direction == .up)
        #expect(trend.assessment == .bad)
        #expect(trend.ratio == Decimal(string: "0.25"))
    }

    @Test func fallingExpensesAreGood() {
        let trend = TrendChange(current: 1200, previous: 1600, growthIsGood: false)

        #expect(trend.direction == .down)
        #expect(trend.assessment == .good)
    }

    @Test func noPreviousValueIsNeutral() {
        let trend = TrendChange(current: 500, previous: 0, growthIsGood: true)

        #expect(trend.ratio == 0)
        #expect(trend.direction == .flat)
        #expect(trend.assessment == .neutral)
    }

    @Test func noChangeIsNeutral() {
        #expect(TrendChange(current: 100, previous: 100, growthIsGood: false).assessment == .neutral)
    }

    /// −500 against −1000 is an improvement: the change is taken against the size of the previous value.
    @Test func negativeBalanceThatShrinksIsGrowth() {
        let trend = TrendChange(current: -500, previous: -1000, growthIsGood: true)

        #expect(trend.ratio == Decimal(string: "0.5"))
        #expect(trend.direction == .up)
        #expect(trend.assessment == .good)
    }

    @Test func ratioIsFormattedWithAtMostOneDecimal() {
        let locale = Locale(identifier: "en_US")

        #expect(TrendChange(current: 1125, previous: 1000, growthIsGood: true).formattedRatio(locale: locale) == "12.5%")
        #expect(TrendChange(current: 1100, previous: 1000, growthIsGood: true).formattedRatio(locale: locale) == "10%")
        #expect(TrendChange(current: 1, previous: 3, growthIsGood: true).formattedRatio(locale: locale) == "66.7%")
    }
}

