import Foundation
import Testing
@testable import Finwaze

struct ReferenceDataMapperTests {
    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(json.utf8))
    }

    @Test func mapsAccountWithNestedCurrency() throws {
        let dto = try decode(AccountDto.self, #"{"id": 7, "name": "Cash", "currencies": {"code": "UAH"}}"#)

        #expect(ReferenceDataMapper.toAccount(dto) == Account(id: 7, name: "Cash", currencyCode: "UAH"))
    }

    @Test func mapsCurrency() throws {
        let dto = try decode(
            CurrencyDto.self,
            #"{"id": 1, "code": "CZK", "name": "Czech Koruna", "country_name": "Czechia"}"#
        )

        #expect(ReferenceDataMapper.toCurrency(dto) == Currency(id: 1, code: "CZK", name: "Czech Koruna", countryName: "Czechia"))
    }

    @Test func mapsGroup() throws {
        let dto = try decode(
            GroupDto.self,
            #"{"id": 3, "name": "Car", "transaction_type": "expense", "color": null}"#
        )

        #expect(ReferenceDataMapper.toGroup(dto) == CategoryGroup(id: 3, name: "Car", transactionType: .expense, color: nil))
    }

    @Test func mapsCategory() throws {
        let dto = try decode(
            CategoryDto.self,
            ##"{"id": 9, "name": "Fuel", "group_id": 3, "color": "#ff0000"}"##
        )

        #expect(ReferenceDataMapper.toCategory(dto) == Finwaze.Category(id: 9, name: "Fuel", groupID: 3, color: "#ff0000"))
    }
}
