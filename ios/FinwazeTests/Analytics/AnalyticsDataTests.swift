import Foundation
import Testing
@testable import Finwaze

/// Analytics' mapper, RPC parameters and pure logic (`ANL-01…06`).
struct AnalyticsDataTests {
    private func calendar(_ identifier: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: identifier)!
        return calendar
    }

    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(type, from: Data(json.utf8))
    }

    // MARK: Summary (ANL-02)

    @Test func summaryKeepsDecimalsExact() throws {
        let dto = try decode([AnalyticsSummaryDto].self, """
            [{"monthly_income": 3200.1, "previous_monthly_income": 0.1, "monthly_expense": 1573.25,
              "previous_monthly_expense": 1820, "total_balance": -27500.55, "previous_total_balance": 25900,
              "income_transaction_count": 2, "expense_transaction_count": 31,
              "income_groups_count": 1, "expense_groups_count": 7}]
            """).first

        let summary = AnalyticsMapper.toSummary(dto)

        #expect(summary.monthlyIncome == Decimal(string: "3200.1"))
        #expect(summary.previousMonthlyIncome == Decimal(string: "0.1"))
        #expect(summary.monthlyExpense == Decimal(string: "1573.25"))
        #expect(summary.totalBalance == Decimal(string: "-27500.55"))
        #expect(summary.expenseTransactionCount == 31)
        #expect(summary.expenseGroupsCount == 7)
    }

    @Test func summaryTreatsNullAndMissingRowAsZero() throws {
        let dto = try decode([AnalyticsSummaryDto].self, """
            [{"monthly_income": null, "previous_monthly_income": null, "monthly_expense": null,
              "previous_monthly_expense": null, "total_balance": null, "previous_total_balance": null,
              "income_transaction_count": 0, "expense_transaction_count": 0,
              "income_groups_count": 0, "expense_groups_count": 0}]
            """).first

        #expect(AnalyticsMapper.toSummary(dto) == .zero)
        #expect(AnalyticsMapper.toSummary(nil) == .zero)
    }

    // MARK: Daily overview (ANL-03)

    /// The server's `DATE` is a calendar day: west or east of UTC it stays the 30th.
    @Test(arguments: ["America/New_York", "Europe/Kyiv", "UTC"])
    func dayStaysTheSameInAnyTimeZone(_ timeZone: String) throws {
        let dto = try decode(DailyOverviewPointDto.self, """
            {"day": "2026-09-30", "daily_income": 0, "daily_expense": 85.5, "running_balance": -120.25}
            """)
        let device = calendar(timeZone)

        let point = try AnalyticsMapper.toDailyPoint(dto, calendar: device)

        #expect(point.dayOfMonth == 30)
        #expect(device.dateComponents([.year, .month, .day], from: point.day) == DateComponents(year: 2026, month: 9, day: 30))
        #expect(point.expense == Decimal(string: "85.5"))
        #expect(point.balance == Decimal(string: "-120.25"))
    }

    @Test func unreadableDayIsAnError() throws {
        let dto = try decode(DailyOverviewPointDto.self, #"{"day": "30/09", "daily_income": 0, "daily_expense": 0, "running_balance": 0}"#)

        #expect(throws: AnalyticsMapper.MappingError.invalidDay("30/09")) {
            try AnalyticsMapper.toDailyPoint(dto)
        }
    }

    // MARK: Statistics (ANL-05)

    @Test func groupAmountsTreatNullAsZero() throws {
        let dto = try decode(AnalyticsGroupAmountsDto.self, """
            {"group_id": 4, "group_name": "Housing", "income_amount": null, "expense_amount": 1200.5}
            """)

        #expect(AnalyticsMapper.toGroupAmounts(dto) == GroupAmounts(id: 4, name: "Housing", income: 0, expense: Decimal(string: "1200.5")!))
    }

    // MARK: Budgets vs Expenses (ANL-04)

    @Test func yearIsInMonthOrder() throws {
        let dtos = try decode([MonthlyBudgetExpenseDto].self, """
            [{"month": "2026-02-01", "budget_amount": 1550, "expense_amount": 1578.4},
             {"month": "2026-01-01", "budget_amount": null, "expense_amount": 20},
             {"month": "2026-12-01", "budget_amount": 0, "expense_amount": 0}]
            """)

        let months = try AnalyticsMapper.toYear(dtos)

        #expect(months.map(\.month) == [
            YearMonth(year: 2026, month: 1), YearMonth(year: 2026, month: 2), YearMonth(year: 2026, month: 12),
        ])
        #expect(months[0].budget == 0)
        #expect(months[1] == MonthlyBudgetExpense(month: YearMonth(year: 2026, month: 2), budget: 1550, expense: Decimal(string: "1578.4")!))
    }

    @Test func unreadableMonthIsAnError() throws {
        let dto = try decode(MonthlyBudgetExpenseDto.self, #"{"month": "September", "budget_amount": 0, "expense_amount": 0}"#)

        #expect(throws: AnalyticsMapper.MappingError.invalidMonth("September")) {
            try AnalyticsMapper.toMonthlyBudgetExpense(dto)
        }
    }

    // MARK: Parameters (ANL-01)

    private func json(_ value: some Encodable) throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: JSONEncoder().encode(value)) as? [String: Any] ?? [:]
    }

    @Test func paramsSendTheMonthCurrencyAndAccounts() throws {
        let query = AnalyticsQuery(month: YearMonth(year: 2026, month: 9), currencyCode: "UAH", accountIDs: [7, 3])

        let params = try json(AnalyticsParams(query))

        #expect(params["p_month"] as? String == "2026-09-01")
        #expect(params["p_currency_code"] as? String == "UAH")
        #expect(params["p_account_ids"] as? [Int] == [3, 7])
    }

    /// Without a choice the key is left out, so the function's `DEFAULT NULL` counts every account.
    @Test func paramsWithoutAccountsLeaveTheKeyOut() throws {
        let query = AnalyticsQuery(month: YearMonth(year: 2026, month: 1), currencyCode: "USD", accountIDs: [])

        let params = try json(AnalyticsParams(query))

        #expect(Set(params.keys) == ["p_month", "p_currency_code"])
    }

    @Test func yearParams() throws {
        let params = try json(AnalyticsYearParams(year: 2026, currencyCode: "EUR"))

        #expect(params["p_year"] as? Int == 2026)
        #expect(params["p_currency_code"] as? String == "EUR")
    }

    // MARK: Comparison (ANL-02)

    @Test func comparisonIsMoreLessOrTheSame() {
        let more = SummaryComparison(current: 1200, previous: 1000)
        let less = SummaryComparison(current: -500, previous: 300)
        let same = SummaryComparison(current: 75, previous: 75)

        #expect(more.direction == .more && more.difference == 200)
        // The difference is its size, never negative.
        #expect(less.direction == .less && less.difference == 800)
        #expect(same.direction == .same && same.difference == 0)
    }

    // MARK: Currency (DASH-01, GEN-11)

    @Test func currencyIsThePickedThenThePrimaryThenTheFirst() {
        let codes = ["EUR", "UAH", "USD"]

        #expect(CurrencySelection.currencyCode(picked: "UAH", among: codes, primary: "USD") == "UAH")
        #expect(CurrencySelection.currencyCode(picked: nil, among: codes, primary: "USD") == "USD")
        #expect(CurrencySelection.currencyCode(picked: "CZK", among: codes, primary: "USD") == "USD")
        #expect(CurrencySelection.currencyCode(picked: "CZK", among: codes, primary: "PLN") == "EUR")
        #expect(CurrencySelection.currencyCode(picked: nil, among: [], primary: "USD") == nil)
    }
}
