import Foundation
import Testing
@testable import Finwaze

struct AccountSettingsDataTests {
    private func json<T: Encodable>(_ value: T) throws -> [String: Any] {
        try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(value)) as? [String: Any])
    }

    @Test func mapsDetailsRow() throws {
        let row = #"{"id": 5, "name": "Cash", "currency_code": "UAH", "currency_id": 1, "balance": -12.5, "can_delete": false}"#

        let details = WalletMapper.toDetails(try JSONDecoder().decode(AccountDetailsDto.self, from: Data(row.utf8)))

        #expect(details == AccountDetails(id: 5, name: "Cash", currencyID: 1, currencyCode: "UAH", balance: Decimal(string: "-12.5")!, canDelete: false))
    }

    @Test func updateLeavesOutAnUnchangedCurrency() throws {
        #expect(try json(WalletMapper.toDto(AccountUpdate(name: "Cash", currencyID: 2))) as NSDictionary == ["name": "Cash", "currency_id": 2])
        #expect(try json(WalletMapper.toDto(AccountUpdate(name: "Cash", currencyID: nil))) as NSDictionary == ["name": "Cash"])
    }

    @Test func adjustmentUsesTheFunctionsParameterNames() throws {
        let adjustment = BalanceAdjustment(
            accountID: 5, targetBalance: Decimal(string: "-250.5")!,
            balanceDate: Date(timeIntervalSince1970: 1_790_500_500), localOffset: LocalOffset(seconds: 10_800)
        )

        let body = try json(WalletMapper.toDto(adjustment))

        #expect(body["p_account_id"] as? Int == 5)
        #expect((body["p_target_balance"] as? NSNumber)?.decimalValue == Decimal(string: "-250.5"))
        #expect(body["p_local_offset"] as? String == "+03:00")
        #expect(body["p_balance_date"] as? String == "2026-09-27T09:15:00.000Z")
        #expect(body["p_comment"] == nil)
    }

    @Test func demoAccountsWithTransactionsAreLocked() async throws {
        let repository = DemoWalletRepository()

        #expect(try await repository.accountDetails(id: 1)?.canDelete == false)
        #expect(try await repository.accountDetails(id: 2)?.canDelete == false)
        #expect(try await repository.accountDetails(id: 3)?.canDelete == true)
        #expect(try await repository.accountDetails(id: 99) == nil)
    }

    @Test func demoWritesChangeNothing() async throws {
        let repository = DemoWalletRepository()
        let before = try await repository.accountDetails(id: 3)

        #expect(try await repository.updateAccount(id: 3, AccountUpdate(name: "Changed", currencyID: 1)))
        try await repository.adjustBalance(
            BalanceAdjustment(accountID: 3, targetBalance: 1, balanceDate: .now, localOffset: LocalOffset(seconds: 0))
        )
        try await repository.deleteAccount(id: 3)

        #expect(try await repository.accountDetails(id: 3) == before)
        #expect(try await repository.accounts().count == 3)
    }
}
