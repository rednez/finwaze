import Foundation
import Testing
@testable import Finwaze

struct WalletMapperTests {
    private func decodeRow(balance: String) throws -> WalletAccount {
        let json = #"{"id": 1, "name": "Cash", "currency_id": 2, "currency_code": "UAH", "balance": \#(balance), "can_delete": true}"#
        return WalletMapper.toAccount(try JSONDecoder().decode(WalletAccountDto.self, from: Data(json.utf8)))
    }

    @Test func mapsRow() throws {
        #expect(try decodeRow(balance: "18500") == WalletAccount(id: 1, name: "Cash", currencyCode: "UAH", balance: 18500))
    }

    /// `NUMERIC` from PostgREST must reach `Decimal` without a detour through `Double`.
    @Test(arguments: ["0.1", "0.3", "-12.5", "1234567.89", "99999999999999.99"])
    func decodesNumericWithoutLosingPrecision(_ text: String) throws {
        let expected = try #require(Decimal(string: text, locale: Locale(identifier: "en_US_POSIX")))

        #expect(try decodeRow(balance: text).balance == expected)
    }

    @Test func sortsByNameLikeFinder() {
        let accounts = ["Savings", "card 10", "Card 2", "Cash", "Ощадний"].enumerated().map {
            WalletAccount(id: Int64($0.offset), name: $0.element, currencyCode: "UAH", balance: 0)
        }

        #expect(WalletMapper.sortedByName(accounts).map(\.name) == ["Card 2", "card 10", "Cash", "Savings", "Ощадний"])
    }

    // MARK: Widgets (ACC-03, ACC-05)

    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(type, from: Data(json.utf8))
    }

    /// The day is a calendar date: it stays the 30th wherever the device is, east or west of UTC.
    @Test(arguments: ["America/New_York", "Europe/Kyiv", "UTC"])
    func dayStaysTheSameInEveryTimeZone(_ identifier: String) throws {
        let timeZone = try #require(TimeZone(identifier: identifier))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let dto = try decode(DailyCashFlowDto.self, #"{"day": "2026-09-30", "total_income": 0.1, "total_expense": -12.35}"#)

        let day = try WalletMapper.toDailyCashFlow(dto, timeZone: timeZone)

        #expect(calendar.dateComponents([.year, .month, .day, .hour], from: day.day)
            == DateComponents(year: 2026, month: 9, day: 30, hour: 0))
        #expect(day.income == Decimal(string: "0.1"))
        #expect(day.expense == Decimal(string: "12.35"))
    }

    @Test func invalidDayIsAnError() throws {
        let dto = try decode(DailyCashFlowDto.self, #"{"day": "30.09.2026", "total_income": 0, "total_expense": 0}"#)

        #expect(throws: WalletMapper.MappingError.invalidDay("30.09.2026")) {
            try WalletMapper.toDailyCashFlow(dto)
        }
    }

    @Test func groupAmountsTakeExpensesAsPositive() throws {
        let dto = try decode(
            GroupAmountsDto.self,
            #"{"group_id": 4, "group_name": "Housing", "total_income": null, "total_expense": -1200.5}"#
        )

        #expect(WalletMapper.toGroupAmounts(dto) == GroupAmounts(id: 4, name: "Housing", income: 0, expense: 1200.5))
    }
}
