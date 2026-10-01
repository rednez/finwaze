import Foundation
import Testing
@testable import Finwaze

@MainActor
struct DashboardViewModelTests {
    private let repository = FakeDashboardRepository()
    private let preferences = DevicePreferences(defaults: makeTestDefaults())

    private let usdTotals = DashboardTotals(
        totalBalance: 9000, monthlyIncome: 3200, monthlyExpense: 1430,
        previousTotalBalance: 7330, previousMonthlyIncome: 3200, previousMonthlyExpense: 1578
    )
    private let eurTotals = DashboardTotals(
        totalBalance: 850, monthlyIncome: 0, monthlyExpense: 40,
        previousTotalBalance: 890, previousMonthlyIncome: 0, previousMonthlyExpense: 0
    )
    private let goal = SavingsGoal(
        id: 101, name: "Emergency Fund", currencyCode: "USD", targetDate: .now, status: .inProgress,
        targetAmount: 10000, accumulatedAmount: 5800, hasTransfers: true
    )

    private func makeViewModel(currency: String? = "USD") async throws -> DashboardViewModel {
        preferences.primaryCurrencyCode = currency
        repository.setTotals(usdTotals, currencyCode: "USD")
        repository.setTotals(eurTotals, currencyCode: "EUR")
        repository.setBudgets([CategoryBudget(name: "Rent", amount: 1200)], currencyCode: "USD")
        // Last month's, which always has more than three, unlike the current one on its first days.
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
        repository.setRecentTransactions(Array(DemoData.transactions(inMonthOf: lastMonth).prefix(3)))
        repository.setGoals([goal])
        return DashboardViewModel(repository: repository, preferences: preferences)
    }

    // MARK: Loading (DASH-02…08)

    @Test func startsLoading() async throws {
        let viewModel = try await makeViewModel()

        #expect(viewModel.totals == .loading)
        #expect(viewModel.cashFlow == .loading)
        #expect(viewModel.budget == .loading)
        #expect(viewModel.recentTransactions == .loading)
        #expect(viewModel.goals == .loading)
    }

    @Test func loadsEveryCardInThePrimaryCurrency() async throws {
        let viewModel = try await makeViewModel()

        await viewModel.load(dataVersion: 0)

        #expect(viewModel.totals == .loaded(usdTotals))
        #expect(viewModel.cashFlow == .loaded([]))
        #expect(viewModel.budget == .loaded(SliceSummary(budgets: [CategoryBudget(name: "Rent", amount: 1200)])))
        #expect(viewModel.recentTransactions.value?.count == 3)
        #expect(viewModel.goals == .loaded([goal]))
        #expect(repository.currencies(.totals) == ["USD"])
        #expect(repository.currencies(.cashFlow) == ["USD"])
        #expect(repository.currencies(.budget) == ["USD"])
    }

    @Test func noBudgetInTheCurrencyIsAnEmptyRing() async throws {
        let viewModel = try await makeViewModel(currency: "EUR")

        await viewModel.load(dataVersion: 0)

        #expect(viewModel.budget.value?.slices.isEmpty == true)
    }

    // MARK: Primary currency (DASH-01)

    @Test func usesThePrimaryCurrency() async throws {
        let viewModel = try await makeViewModel()

        #expect(viewModel.currencyCode == "USD")
    }

    @Test func changingTheCurrencyReloadsOnlyItsCards() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)

        preferences.primaryCurrencyCode = "EUR"
        await viewModel.load(dataVersion: 0)

        #expect(viewModel.currencyCode == "EUR")
        #expect(viewModel.totals == .loaded(eurTotals))
        #expect(repository.currencies(.totals) == ["USD", "EUR"])
        #expect(repository.currencies(.cashFlow) == ["USD", "EUR"])
        #expect(repository.currencies(.budget) == ["USD", "EUR"])
        #expect(repository.loads(.recentTransactions) == 1)
        #expect(repository.loads(.goals) == 1)
    }

    @Test func comingBackWithoutChangesLoadsNothing() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)

        await viewModel.load(dataVersion: 0)

        for card in DashboardViewModel.Card.allCases {
            #expect(repository.loads(card) == 1)
        }
    }

    /// Without a primary currency — only without accounts — the currency's cards cannot load.
    @Test func noCurrencyFailsOnlyTheCurrencysCards() async throws {
        let viewModel = try await makeViewModel(currency: nil)

        await viewModel.load(dataVersion: 0)

        #expect(viewModel.totals == .failed)
        #expect(viewModel.cashFlow == .failed)
        #expect(viewModel.budget == .failed)
        #expect(viewModel.goals == .loaded([goal]))
        #expect(repository.loads(.totals) == 0)
    }

    // MARK: Changes to the data (GEN-26)

    @Test func changedDataReloadsEveryCard() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)
        let newTotals = DashboardTotals(
            totalBalance: 10000, monthlyIncome: 4200, monthlyExpense: 1430,
            previousTotalBalance: 7330, previousMonthlyIncome: 3200, previousMonthlyExpense: 1578
        )
        repository.setTotals(newTotals, currencyCode: "USD")

        await viewModel.load(dataVersion: 1)

        #expect(viewModel.totals == .loaded(newTotals))
        for card in DashboardViewModel.Card.allCases {
            #expect(repository.loads(card) == 2)
        }
    }

    @Test func refreshReloadsEveryCard() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)

        await viewModel.refresh()

        for card in DashboardViewModel.Card.allCases {
            #expect(repository.loads(card) == 2)
        }
    }

    // MARK: Independent cards (DASH-08)

    @Test func aFailingCardLeavesTheOthersIntact() async throws {
        let viewModel = try await makeViewModel()
        repository.setFails(.cashFlow)

        await viewModel.load(dataVersion: 0)

        #expect(viewModel.cashFlow == .failed)
        #expect(viewModel.totals == .loaded(usdTotals))
        #expect(viewModel.goals == .loaded([goal]))
    }

    @Test func retryReloadsOnlyThatCard() async throws {
        let viewModel = try await makeViewModel()
        repository.setFails(.goals)
        await viewModel.load(dataVersion: 0)
        #expect(viewModel.goals == .failed)

        repository.setFails(.goals, false)
        await viewModel.retry(.goals)

        #expect(viewModel.goals == .loaded([goal]))
        #expect(repository.loads(.goals) == 2)
        #expect(repository.loads(.totals) == 1)
    }

    /// A reload that fails after a successful one shows the error, not stale figures presented as current.
    @Test func failedReloadShowsTheError() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)

        repository.setFails(.totals)
        await viewModel.load(dataVersion: 1)

        #expect(viewModel.totals == .failed)
        #expect(viewModel.budget != .failed)
    }
}
