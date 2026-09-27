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
}
