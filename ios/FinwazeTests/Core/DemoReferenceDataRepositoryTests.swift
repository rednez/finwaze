import Foundation
import Testing
@testable import Finwaze

struct DemoReferenceDataRepositoryTests {
    private let repository = DemoReferenceDataRepository()

    @Test func servesDemoData() async throws {
        #expect(try await repository.regularAccounts().map(\.currencyCode) == ["USD", "UAH", "EUR"])
        #expect(try await repository.currencies().count == 3)
    }

    @Test func everyCategoryBelongsToAGroup() async throws {
        let groupIDs = Set(try await repository.groups().map(\.id))

        #expect(try await repository.categories().allSatisfy { groupIDs.contains($0.groupID) })
    }

    @Test func groupsAreOnlyIncomeOrExpense() async throws {
        let types = Set(try await repository.groups().map(\.transactionType))

        #expect(types == [.income, .expense])
    }

    @Test func accountCurrenciesAreInTheDirectory() async throws {
        let codes = Set(try await repository.currencies().map(\.code))

        #expect(try await repository.regularAccounts().allSatisfy { codes.contains($0.currencyCode) })
    }

    @Test func createAccountIsANoOp() async throws {
        let account = try await repository.createAccount(name: "Card", currencyID: 3)

        #expect(account == Account(id: DemoData.createdRowID, name: "Card", currencyCode: "EUR"))
        #expect(try await repository.regularAccounts() == DemoData.accounts)
    }

    @Test func walletBalancesCoverEveryAccount() async throws {
        let wallet = try await DemoWalletRepository().accounts()

        #expect(Set(wallet.map(\.id)) == Set(DemoData.accounts.map(\.id)))
        #expect(wallet.first { $0.name == "Cash" }?.balance == 18500)
    }
}
