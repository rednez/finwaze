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
}
