import Foundation
import Testing
@testable import Finwaze

@MainActor
struct BudgetViewModelTests {
    private let repository = FakeBudgetRepository()
    private let preferences = DevicePreferences(defaults: makeTestDefaults())
    private let filter = BudgetFilter()

    private let housing = BudgetItem(id: 4, name: "Housing", planned: 1200, spent: 1200, categoriesCount: 1,
                                     isUnplanned: false)
    private let food = BudgetItem(id: 1, name: "Food", planned: 250, spent: 195, categoriesCount: 2,
                                  isUnplanned: false)
    private let entertainment = BudgetItem(id: 3, name: "Entertainment", planned: 0, spent: 20, categoriesCount: 1,
                                           isUnplanned: true)

    private func query(_ currency: String = "USD", month: YearMonth? = nil, group: Int64? = nil) -> BudgetQuery {
        BudgetQuery(month: month ?? filter.month, currencyCode: currency, groupID: group)
    }

    private func makeViewModel(primary: String? = "USD", groupID: Int64? = nil) async throws -> BudgetViewModel {
        preferences.primaryCurrencyCode = primary
        let referenceData = try await makeReferenceData(FakeReferenceDataRepository(accounts: [
            Account(id: 1, name: "Card", currencyCode: "USD"),
            Account(id: 2, name: "Savings", currencyCode: "EUR"),
        ]))
        repository.setBudgets([housing, food, entertainment], for: query())
        repository.setTotals(BudgetTotals(planned: 1450, spent: 1415), for: query())
        repository.setExpenses([MonthlyExpense(id: 4, name: "Housing", amount: 1200, previousAmount: 1200)],
                               for: query())
        return BudgetViewModel(
            repository: repository,
            referenceData: referenceData,
            preferences: preferences,
            filter: filter,
            groupID: groupID
        )
    }

    // MARK: Loading (BUD-12…14, GEN-23…25)

    @Test func startsLoading() async throws {
        let viewModel = try await makeViewModel()

        #expect(viewModel.budgets == .loading)
        #expect(viewModel.totals == .loading)
        #expect(viewModel.expenses == .loading)
    }

    @Test func loadsEveryCard() async throws {
        let viewModel = try await makeViewModel()

        await viewModel.load(dataVersion: 0)

        #expect(viewModel.budgets == .loaded([housing, food, entertainment]))
        #expect(viewModel.totals == .loaded(BudgetTotals(planned: 1450, spent: 1415)))
        #expect(viewModel.expenses.value?.count == 1)
        #expect(repository.queries(.budgets) == [query()])
    }

    @Test func oneFailingCardLeavesTheOthers() async throws {
        let viewModel = try await makeViewModel()
        repository.setFails(.totals)

        await viewModel.load(dataVersion: 0)

        #expect(viewModel.totals == .failed)
        #expect(viewModel.budgets.value != nil)
        #expect(viewModel.expenses.value != nil)
    }

    @Test func retryReloadsOnlyItsCard() async throws {
        let viewModel = try await makeViewModel()
        repository.setFails(.totals)
        await viewModel.load(dataVersion: 0)
        repository.setFails(.totals, false)

        await viewModel.retry(.totals)

        #expect(viewModel.totals == .loaded(BudgetTotals(planned: 1450, spent: 1415)))
        #expect(repository.loads(.totals) == 2)
        #expect(repository.loads(.budgets) == 1)
    }

    @Test func comingBackWithoutChangesLoadsNothing() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)

        await viewModel.load(dataVersion: 0)

        #expect(repository.callCount == 3)
    }

    /// New data reloads every card but keeps the figures until the new ones arrive (`GEN-26`).
    @Test func newDataReloadsEveryCard() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)

        await viewModel.load(dataVersion: 1)

        #expect(repository.callCount == 6)
        #expect(viewModel.budgets.value?.count == 3)
    }

    // MARK: Month and currency (BUD-11, DASH-01)

    @Test func anotherMonthReloadsEveryCard() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)
        let august = filter.month.adding(months: -1)

        viewModel.shiftMonth(by: -1)
        await viewModel.load(dataVersion: 0)

        #expect(repository.queries(.budgets).last == query(month: august))
        #expect(repository.queries(.totals).last == query(month: august))
        #expect(repository.queries(.expenses).last == query(month: august))
        #expect(viewModel.budgets == .loaded([]))
    }

    @Test func startsInThePrimaryCurrencyAndKeepsIt() async throws {
        let viewModel = try await makeViewModel(primary: "EUR")

        await viewModel.load(dataVersion: 0)
        // The primary currency changes on the Dashboard after the Budget was first opened.
        preferences.primaryCurrencyCode = "USD"

        #expect(viewModel.currencyCode == "EUR")
        #expect(filter.currencyCode == "EUR")
        #expect(repository.queries(.budgets) == [query("EUR")])
    }

    @Test func pickedCurrencyIsNotOverwrittenByThePrimaryOne() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)

        viewModel.selectCurrency("EUR")
        preferences.primaryCurrencyCode = "USD"
        await viewModel.load(dataVersion: 0)

        #expect(viewModel.currencyCode == "EUR")
        #expect(repository.queries(.totals).last == query("EUR"))
    }

    /// A currency no account has any more (e.g. its account was deleted) falls back to the primary one.
    @Test func unknownCurrencyFallsBack() async throws {
        let viewModel = try await makeViewModel()
        filter.currencyCode = "CZK"

        #expect(viewModel.currencyCode == "USD")
        #expect(viewModel.currencyCodes == ["EUR", "USD"])
    }

    // MARK: Filters and actions (BUD-11, BUD-15)

    /// Status and group filters work on the loaded cards: no request.
    @Test func statusAndGroupsFilterWithoutLoading() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)

        filter.status = .overBudget
        #expect(viewModel.visibleBudgets == [entertainment])

        filter.status = nil
        filter.groupIDs = [1, 4]
        #expect(viewModel.visibleBudgets == [housing, food])

        await viewModel.load(dataVersion: 0)
        #expect(repository.callCount == 3)
    }

    @Test func groupOptionsAreByName() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)

        #expect(viewModel.groupOptions.map(\.name) == ["Entertainment", "Food", "Housing"])
    }

    @Test func editOnlyWithAPlan() async throws {
        let viewModel = try await makeViewModel()
        #expect(!viewModel.hasPlan)

        await viewModel.load(dataVersion: 0)
        #expect(viewModel.hasPlan)

        // Only unplanned spending: "Add budget", not "Edit budget" (unlike the web).
        repository.setTotals(BudgetTotals(planned: 0, spent: 20), for: query())
        await viewModel.refresh()
        #expect(!viewModel.hasPlan)
    }

    // MARK: A group's screen (BUD-17)

    @Test func groupScreenAsksForItsGroupAndIgnoresTheGroupFilters() async throws {
        let viewModel = try await makeViewModel(groupID: 1)
        let groceries = BudgetItem(id: 1, name: "Groceries", planned: 250, spent: 150, categoriesCount: nil,
                                   isUnplanned: false)
        repository.setBudgets([groceries], for: query(group: 1))
        filter.status = .overBudget
        filter.groupIDs = [4]

        await viewModel.load(dataVersion: 0)

        #expect(repository.queries(.budgets) == [query(group: 1)])
        #expect(repository.queries(.totals) == [query(group: 1)])
        #expect(repository.queries(.expenses) == [query(group: 1)])
        #expect(viewModel.visibleBudgets == [groceries])
    }
}
