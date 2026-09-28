import Foundation
import Testing
@testable import Finwaze

/// Analytics' filters and cards (`ANL-01…06`).
@MainActor
struct AnalyticsViewModelTests {
    private let repository = FakeAnalyticsRepository()
    private let budget = FakeBudgetRepository()
    private let referenceRepository = FakeReferenceDataRepository(accounts: [
        Account(id: 1, name: "Main Card", currencyCode: "USD"),
        Account(id: 2, name: "Cash", currencyCode: "USD"),
        Account(id: 3, name: "Euro Card", currencyCode: "EUR"),
    ])
    private let preferences = DevicePreferences(defaults: makeTestDefaults())
    private let referenceData = ReferenceDataStore()
    private let september = YearMonth(year: 2026, month: 9)

    private func makeViewModel(primary: String? = "USD") async throws -> AnalyticsViewModel {
        preferences.primaryCurrencyCode = primary
        let now = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 16, hour: 12))!
        try await loadReferenceData()
        return AnalyticsViewModel(
            repository: repository,
            budgetRepository: budget,
            referenceData: referenceData,
            preferences: preferences,
            filter: AnalyticsFilter(now: now)
        )
    }

    private func query(
        _ month: YearMonth? = nil,
        currencyCode: String = "USD",
        accounts: Set<Int64> = []
    ) -> AnalyticsQuery {
        AnalyticsQuery(month: month ?? september, currencyCode: currencyCode, accountIDs: accounts)
    }

    // MARK: Currency (ANL-01, DASH-01)

    @Test func startsInThePrimaryCurrencyAndFollowsIt() async throws {
        let viewModel = try await makeViewModel()

        #expect(viewModel.currencyCodes == ["EUR", "USD"])
        #expect(viewModel.currencyCode == "USD")

        preferences.primaryCurrencyCode = "EUR"
        #expect(viewModel.currencyCode == "EUR")
    }

    @Test func aPickedCurrencyStaysWhenThePrimaryOneChanges() async throws {
        let viewModel = try await makeViewModel()

        viewModel.selectCurrency("EUR")
        preferences.primaryCurrencyCode = "USD"

        #expect(viewModel.currencyCode == "EUR")
    }

    // MARK: Accounts (ANL-01)

    @Test func offersTheCurrencysAccountsByName() async throws {
        let viewModel = try await makeViewModel()

        #expect(viewModel.accounts.map(\.name) == ["Cash", "Main Card"])
        #expect(viewModel.selectedAccountIDs.isEmpty)
    }

    @Test func pickedAccountsNarrowTheQuery() async throws {
        let viewModel = try await makeViewModel()

        viewModel.setAccount(1, isSelected: true)
        #expect(viewModel.query == query(accounts: [1]))

        viewModel.setAccount(1, isSelected: false)
        #expect(viewModel.query == query())
    }

    @Test func anotherCurrencyClearsTheAccounts() async throws {
        let viewModel = try await makeViewModel()
        viewModel.setAccount(1, isSelected: true)

        viewModel.selectCurrency("EUR")

        #expect(viewModel.filter.accountIDs.isEmpty)
        #expect(viewModel.query == query(currencyCode: "EUR"))
        #expect(viewModel.accounts.map(\.name) == ["Euro Card"])
    }

    @Test func anAccountThatIsGoneDropsOut() async throws {
        let viewModel = try await makeViewModel()
        viewModel.setAccount(1, isSelected: true)
        viewModel.setAccount(2, isSelected: true)

        // The Main Card is deleted, and Cash moves to euros.
        referenceRepository.setAccounts([
            Account(id: 2, name: "Cash", currencyCode: "EUR"),
            Account(id: 4, name: "Card", currencyCode: "USD"),
        ])
        try await loadReferenceData()

        #expect(viewModel.selectedAccountIDs.isEmpty)
        #expect(viewModel.query == query())
    }

    // MARK: Loading (ANL-02…05, GEN-26)

    @Test func loadsEveryCardForTheFilters() async throws {
        let viewModel = try await makeViewModel()
        let summary = AnalyticsSummary.zero
        repository.setSummary(summary, for: query())

        await viewModel.load(dataVersion: 0)

        #expect(viewModel.summary.state == .loaded(summary))
        #expect(repository.queries(.summary) == [query()])
        // The month and the one before, for the two lines (`ANL-03`).
        #expect(Set(repository.queries(.dailyOverview)) == [query(), query(september.adding(months: -1))])
        #expect(repository.queries(.amountsByGroup) == [query()])
        #expect(budget.queries(.budgets) == [BudgetQuery(month: september, currencyCode: "USD", groupID: nil)])
        #expect(repository.yearKeys == [AnalyticsYearKey(year: 2026, currencyCode: "USD")])
    }

    @Test func comingBackWithoutChangesLoadsNothing() async throws {
        let viewModel = try await makeViewModel()

        await viewModel.load(dataVersion: 0)
        await viewModel.load(dataVersion: 0)

        #expect(repository.queries(.summary).count == 1)
        #expect(repository.queries(.dailyOverview).count == 2)
        #expect(repository.queries(.amountsByGroup).count == 1)
        #expect(repository.yearKeys.count == 1)
    }

    @Test func changedDataReloadsEveryCard() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)

        await viewModel.load(dataVersion: 1)

        #expect(repository.queries(.summary).count == 2)
        #expect(repository.queries(.amountsByGroup).count == 2)
        #expect(repository.yearKeys.count == 2)
    }

    /// "Budgets vs Expenses" has its own year and no accounts (`ANL-04`).
    @Test func monthAndAccountsDoNotReloadBudgetsVsExpenses() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)

        viewModel.shiftMonth(by: -1)
        await viewModel.load(dataVersion: 0)
        viewModel.setAccount(2, isSelected: true)
        await viewModel.load(dataVersion: 0)

        #expect(repository.queries(.summary) == [query(), query(september.adding(months: -1)), query(september.adding(months: -1), accounts: [2])])
        #expect(repository.yearKeys == [AnalyticsYearKey(year: 2026, currencyCode: "USD")])
    }

    @Test func yearReloadsOnlyBudgetsVsExpenses() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)

        viewModel.shiftBudgetYear(by: -1)
        await viewModel.load(dataVersion: 0)

        #expect(repository.yearKeys.map(\.year) == [2026, 2025])
        #expect(repository.queries(.summary).count == 1)
        #expect(repository.queries(.dailyOverview).count == 2)
        #expect(repository.queries(.amountsByGroup).count == 1)
        #expect(viewModel.filter.month == september)
    }

    @Test func aFailingCardLeavesTheOthersBe() async throws {
        let viewModel = try await makeViewModel()
        repository.setFails(.summary)

        await viewModel.load(dataVersion: 0)

        #expect(viewModel.summary.state == .failed)
        #expect(viewModel.overview.state.value != nil)
        #expect(viewModel.statistics.state.value != nil)
        #expect(viewModel.budgetsVsExpenses.state.value != nil)

        repository.setFails(.summary, false)
        await viewModel.summary.refresh()
        #expect(viewModel.summary.state == .loaded(.zero))
    }

    @Test func switchingTheMetricOrTheModeLoadsNothing() async throws {
        let viewModel = try await makeViewModel()
        await viewModel.load(dataVersion: 0)

        viewModel.overviewMetric = .expense
        viewModel.statisticsMode = .budget
        await viewModel.load(dataVersion: 0)

        #expect(repository.queries(.dailyOverview).count == 2)
        #expect(repository.queries(.amountsByGroup).count == 1)
        #expect(budget.queries(.budgets).count == 1)
    }

    /// The budget knows no accounts: the amounts follow the picked account, the budget does not (`ANL-05`).
    @Test func budgetIgnoresTheAccounts() async throws {
        let viewModel = try await makeViewModel()
        viewModel.setAccount(1, isSelected: true)

        await viewModel.load(dataVersion: 0)

        #expect(repository.queries(.amountsByGroup) == [query(accounts: [1])])
        #expect(budget.queries(.budgets) == [BudgetQuery(month: september, currencyCode: "USD", groupID: nil)])
    }

    // MARK: Statistics (ANL-05)

    @Test func statisticsShowTheModesGroupsWithAnAmountOnly() async throws {
        let viewModel = try await makeViewModel()
        let statistics = GroupStatistics(
            amounts: [
                GroupAmounts(id: 1, name: "Food", income: 0, expense: 195),
                GroupAmounts(id: 5, name: "Salary", income: 3200, expense: 0),
                GroupAmounts(id: 6, name: "Refunds", income: 20, expense: 5),
            ],
            budgets: [
                BudgetItem(id: 4, name: "Housing", planned: 1200, spent: 1200, categoriesCount: 1, isUnplanned: false),
                BudgetItem(id: 3, name: "Fun", planned: 0, spent: 20, categoriesCount: 1, isUnplanned: true),
            ]
        )

        #expect(viewModel.statisticsSummary(of: statistics).slices.map(\.name) == ["Food", "Refunds"])

        viewModel.statisticsMode = .income
        #expect(viewModel.statisticsSummary(of: statistics).slices.map(\.name) == ["Salary", "Refunds"])
        #expect(viewModel.statisticsSummary(of: statistics).total == 3220)

        viewModel.statisticsMode = .budget
        #expect(viewModel.statisticsSummary(of: statistics).slices.map(\.name) == ["Housing"])
    }

    @Test func eightGroupsShowSixAndOther() async throws {
        let viewModel = try await makeViewModel()
        let amounts = (1...8).map { GroupAmounts(id: Int64($0), name: "G\($0)", income: 0, expense: Decimal($0 * 10)) }

        let summary = viewModel.statisticsSummary(of: GroupStatistics(amounts: amounts, budgets: []))

        #expect(summary.slices.count == 7)
        #expect(summary.slices.last == ChartSlice(id: 6, name: nil, amount: 30)) // 20 + 10
        let shares = summary.slices.reduce(Decimal(0)) { $0 + summary.share(of: $1) }
        #expect(abs(shares - 1) < Decimal(string: "0.000001")!)
    }

    // MARK: Summary cards (ANL-02)

    @Test func summaryCardsCompareWithLastMonth() async throws {
        let viewModel = try await makeViewModel()
        let summary = AnalyticsSummary(
            monthlyIncome: 3200,
            previousMonthlyIncome: 3200,
            monthlyExpense: 1430,
            previousMonthlyExpense: 1578,
            totalBalance: 9000,
            previousTotalBalance: 7330,
            incomeTransactionCount: 1,
            expenseTransactionCount: 6,
            incomeGroupsCount: 1,
            expenseGroupsCount: 4
        )

        #expect(viewModel.comparison(.balance, in: summary).direction == .more)
        #expect(viewModel.comparison(.balance, in: summary).difference == 1670)
        #expect(viewModel.comparison(.expenses, in: summary).direction == .less)
        #expect(viewModel.comparison(.expenses, in: summary).difference == 148)
        #expect(viewModel.comparison(.income, in: summary).direction == .same)
        // The balance counts both kinds, like the web.
        #expect(SummaryKind.balance.transactionCount(in: summary) == 7)
        #expect(SummaryKind.balance.groupsCount(in: summary) == 5)
        #expect(SummaryKind.expenses.groupsCount(in: summary) == 4)
    }

    /// Loads the accounts the view model reads, as the app does after a change to them.
    private func loadReferenceData() async throws {
        try await referenceData.load(using: .fake(referenceData: referenceRepository))
    }
}
