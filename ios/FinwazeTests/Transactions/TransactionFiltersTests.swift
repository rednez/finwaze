import Foundation
import Testing
@testable import Finwaze

struct TransactionFiltersTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Kyiv")!
        return calendar
    }()

    /// 27 September 2026, 12:15 in Kyiv.
    private let now = Date(timeIntervalSince1970: 1_790_500_500)

    private let categories = [
        Finwaze.Category(id: 1, name: "Groceries", groupID: 1, color: nil),
        Finwaze.Category(id: 2, name: "Restaurants", groupID: 1, color: nil),
        Finwaze.Category(id: 3, name: "Taxi", groupID: 2, color: nil),
    ]

    private func makeFilters() -> TransactionFilters {
        TransactionFilters(now: now, calendar: calendar)
    }

    private func month(_ year: Int, _ month: Int) -> YearMonth {
        YearMonth(year: year, month: month)
    }

    @Test func startsOnCurrentMonthWithEverythingAll() throws {
        let filters = makeFilters()
        let query = try #require(filters.query(categories: categories))

        #expect(query == TransactionQuery(month: month(2026, 9), type: nil, categoryIDs: nil, currencyCode: nil, accountID: nil))
        #expect(query.month.firstDayParameter == "2026-09-01")
    }

    @Test func shiftsMonthAcrossYears() {
        var filters = makeFilters()

        filters.shiftMonth(by: 4)
        #expect(filters.month == month(2027, 1))

        filters.shiftMonth(by: -5)
        #expect(filters.month == month(2026, 8))
    }

    @Test func changingCurrencyResetsAccount() {
        var filters = makeFilters()
        filters.currencyCode = "UAH"
        filters.accountID = 2

        filters.currencyCode = "UAH"
        #expect(filters.accountID == 2)

        filters.currencyCode = "EUR"
        #expect(filters.accountID == nil)
    }

    @Test func changingGroupResetsCategory() {
        var filters = makeFilters()
        filters.groupID = 1
        filters.categoryID = 2

        filters.groupID = 1
        #expect(filters.categoryID == 2)

        filters.groupID = 2
        #expect(filters.categoryID == nil)
    }

    @Test func groupWithoutCategoryMeansAllItsCategories() {
        var filters = makeFilters()
        filters.groupID = 1

        #expect(filters.query(categories: categories)?.categoryIDs == [1, 2])
    }

    @Test func chosenCategoryNarrowsToIt() {
        var filters = makeFilters()
        filters.groupID = 1
        filters.categoryID = 2

        #expect(filters.query(categories: categories)?.categoryIDs == [2])
    }

    /// The server reads an empty category list as "any", so a group without categories matches nothing here.
    @Test func groupWithoutCategoriesMatchesNothing() {
        var filters = makeFilters()
        filters.groupID = 9

        #expect(filters.query(categories: categories) == nil)
    }

    @Test func passesTypeCurrencyAndAccount() {
        var filters = makeFilters()
        filters.type = .transfer
        filters.currencyCode = "EUR"
        filters.accountID = 3

        let query = filters.query(categories: categories)

        #expect(query?.type == .transfer)
        #expect(query?.currencyCode == "EUR")
        #expect(query?.accountID == 3)
    }

    @Test func countsAndResetsActiveFiltersKeepingTheMonth() {
        var filters = makeFilters()
        filters.shiftMonth(by: -1)
        #expect(filters.activeCount == 0)

        filters.type = .expense
        filters.currencyCode = "UAH"
        filters.groupID = 1
        filters.categoryID = 2
        #expect(filters.activeCount == 4)

        filters.reset()

        #expect(filters.activeCount == 0)
        #expect(filters.month == month(2026, 8))
    }
}
