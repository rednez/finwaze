import Foundation
import Testing
@testable import Finwaze

@MainActor
struct TransactionsViewModelTests {
    private let cash = Account(id: 1, name: "Cash", currencyCode: "UAH")
    private let card = Account(id: 2, name: "Card", currencyCode: "EUR")
    private let wallet = Account(id: 3, name: "Wallet", currencyCode: "UAH")

    private func makeViewModel(_ repository: FakeTransactionsRepository) async throws -> TransactionsViewModel {
        let referenceData = try await makeReferenceData(FakeReferenceDataRepository(accounts: [cash, card, wallet]))
        return TransactionsViewModel(repository: repository, referenceData: referenceData)
    }

    @Test func startsLoading() async throws {
        #expect(try await makeViewModel(FakeTransactionsRepository()).state == .loading)
    }

    @Test func showsTransactions() async throws {
        let transactions = [Transaction.fixture(id: 2), .fixture(id: 1)]
        let viewModel = try await makeViewModel(FakeTransactionsRepository(transactions: transactions))

        await viewModel.load()

        #expect(viewModel.state == .loaded(transactions))
    }

    /// `TX-07`: the empty state is for a user without any transaction at all.
    @Test func noTransactionsAtAllIsEmpty() async throws {
        let viewModel = try await makeViewModel(FakeTransactionsRepository(hasTransactions: false))

        await viewModel.load()

        #expect(viewModel.state == .empty)
    }

    /// `TX-07`: filters that match nothing keep the list (and its filters) rather than the empty state.
    @Test func filtersMatchingNothingKeepTheList() async throws {
        let viewModel = try await makeViewModel(FakeTransactionsRepository(transactions: [], hasTransactions: true))

        await viewModel.load()

        #expect(viewModel.state == .loaded([]))
    }

    @Test func failureCanBeRetried() async throws {
        let repository = FakeTransactionsRepository(transactions: [.fixture()], fails: true)
        let viewModel = try await makeViewModel(repository)

        await viewModel.load()
        #expect(viewModel.state == .failed)

        repository.setFails(false)
        await viewModel.load()
        #expect(viewModel.state == .loaded([.fixture()]))
    }

    @Test func loadsWithCurrentFilters() async throws {
        let repository = FakeTransactionsRepository()
        let viewModel = try await makeViewModel(repository)
        viewModel.filters.type = .income
        viewModel.filters.groupID = FakeReferenceDataRepository.food.id

        await viewModel.load()

        #expect(repository.queries.last?.type == .income)
        #expect(repository.queries.last?.categoryIDs == [FakeReferenceDataRepository.groceries.id])
    }

    @Test func groupWithoutCategoriesAsksNothing() async throws {
        let repository = FakeTransactionsRepository(transactions: [.fixture()])
        let viewModel = try await makeViewModel(repository)
        viewModel.filters.groupID = 99

        await viewModel.load()

        #expect(repository.queries.isEmpty)
        #expect(viewModel.state == .loaded([]))
    }

    @Test func accountsFollowTheCurrencyFilter() async throws {
        let viewModel = try await makeViewModel(FakeTransactionsRepository())
        #expect(viewModel.accounts == [cash, card, wallet])
        #expect(viewModel.currencyCodes == ["UAH", "EUR"])

        viewModel.filters.currencyCode = "UAH"

        #expect(viewModel.accounts == [cash, wallet])
    }

    @Test func categoriesFollowTheGroupFilter() async throws {
        let viewModel = try await makeViewModel(FakeTransactionsRepository())
        #expect(viewModel.categories.isEmpty)

        viewModel.filters.groupID = FakeReferenceDataRepository.food.id

        #expect(viewModel.categories == [FakeReferenceDataRepository.groceries])
    }

    @Test func demoListIsFiltered() async throws {
        let referenceData = ReferenceDataStore()
        try await referenceData.load(using: .demo)
        let viewModel = TransactionsViewModel(
            repository: DemoTransactionsRepository(),
            referenceData: referenceData,
            filters: TransactionFilters(now: .now)
        )
        viewModel.filters.shiftMonth(by: -1)
        viewModel.filters.type = .income

        await viewModel.load()

        guard case .loaded(let transactions) = viewModel.state else {
            Issue.record("Expected loaded transactions")
            return
        }
        #expect(transactions.count == 1)
        #expect(transactions.allSatisfy { $0.type == .income })
    }
}
