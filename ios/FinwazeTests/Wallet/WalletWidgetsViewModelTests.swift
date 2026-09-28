import Foundation
import Testing
@testable import Finwaze

/// The Wallet's widgets and their own filters (`ACC-03…06`).
@MainActor
struct WalletWidgetsViewModelTests {
    private let repository = FakeWalletRepository()
    private let preferences = DevicePreferences(defaults: makeTestDefaults())
    private let september = YearMonth(year: 2026, month: 9)

    private let usdDays = [DailyCashFlow(day: .now, income: 3200, expense: 85)]
    private let eurDays = [DailyCashFlow(day: .now, income: 0, expense: 40)]

    private func referenceData(_ currencies: [String] = ["USD", "EUR"]) async throws -> ReferenceDataStore {
        try await makeReferenceData(FakeReferenceDataRepository(accounts: currencies.enumerated().map {
            Account(id: Int64($0.offset + 1), name: "Account \($0.offset)", currencyCode: $0.element)
        }))
    }

    private func makeCashFlow(primary: String? = "USD") async throws -> DailyCashFlowViewModel {
        preferences.primaryCurrencyCode = primary
        repository.setDailyCashFlow(usdDays, currencyCode: "USD")
        repository.setDailyCashFlow(eurDays, currencyCode: "EUR")
        return DailyCashFlowViewModel(repository: repository, referenceData: try await referenceData(), preferences: preferences)
    }

    // MARK: Currency (ACC-06, DASH-01)

    @Test func startsInThePrimaryCurrencyAndFollowsIt() async throws {
        let viewModel = try await makeCashFlow()

        #expect(viewModel.widget.currencyCodes == ["EUR", "USD"])
        #expect(viewModel.widget.currencyCode == "USD")

        preferences.primaryCurrencyCode = "EUR"
        #expect(viewModel.widget.currencyCode == "EUR")
    }

    @Test func aPickedCurrencyStaysWhenThePrimaryOneChanges() async throws {
        let viewModel = try await makeCashFlow()

        viewModel.widget.selectCurrency("EUR")
        preferences.primaryCurrencyCode = "USD"

        #expect(viewModel.widget.currencyCode == "EUR")
    }

    @Test func aCurrencyNoAccountHasFallsBackToThePrimaryOne() async throws {
        preferences.primaryCurrencyCode = "USD"
        let widget = WalletWidgetViewModel<[DailyCashFlow]>(
            referenceData: try await referenceData(["USD"]),
            preferences: preferences
        ) { _ in [] }

        widget.selectCurrency("CZK")

        #expect(widget.currencyCode == "USD")
    }

    @Test func eachWidgetHasItsOwnFilters() async throws {
        let cashFlow = try await makeCashFlow()
        let statistics = WalletStatisticsViewModel(
            repository: repository, referenceData: try await referenceData(), preferences: preferences
        )

        cashFlow.widget.selectCurrency("EUR")
        cashFlow.widget.shiftMonth(by: -1)

        #expect(statistics.widget.currencyCode == "USD")
        #expect(statistics.widget.filter.month == YearMonth(.now, in: .current))
    }

    // MARK: Loading (ACC-03, GEN-26)

    @Test func loadsTheMonthInTheCurrency() async throws {
        let filter = WalletWidgetFilter(now: Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 16))!)
        preferences.primaryCurrencyCode = "USD"
        repository.setAmountsByGroup([GroupAmounts(id: 1, name: "Food", income: 0, expense: 195)], currencyCode: "USD")
        let widget = WalletWidgetViewModel(referenceData: try await referenceData(), preferences: preferences, filter: filter) {
            try await repository.amountsByGroup(month: $0.month, currencyCode: $0.currencyCode)
        }

        await widget.load(dataVersion: 0)

        #expect(widget.state == .loaded([GroupAmounts(id: 1, name: "Food", income: 0, expense: 195)]))
        #expect(repository.amountsByGroupCalls == [.init(month: september, currencyCode: "USD")])
    }

    @Test func comingBackWithoutChangesLoadsNothing() async throws {
        let viewModel = try await makeCashFlow()

        await viewModel.widget.load(dataVersion: 0)
        await viewModel.widget.load(dataVersion: 0)

        #expect(repository.dailyCashFlowCalls.count == 1)
    }

    @Test func changedDataReloadsKeepingTheFigures() async throws {
        let viewModel = try await makeCashFlow()
        await viewModel.widget.load(dataVersion: 0)

        await viewModel.widget.load(dataVersion: 1)

        #expect(repository.dailyCashFlowCalls.count == 2)
        #expect(viewModel.widget.state == .loaded(usdDays))
    }

    @Test func anotherCurrencyReloadsInIt() async throws {
        let viewModel = try await makeCashFlow()
        await viewModel.widget.load(dataVersion: 0)

        viewModel.widget.selectCurrency("EUR")
        await viewModel.widget.load(dataVersion: 0)

        #expect(repository.dailyCashFlowCalls.map(\.currencyCode) == ["USD", "EUR"])
        #expect(viewModel.widget.state == .loaded(eurDays))
    }

    @Test func anotherMonthReloadsIt() async throws {
        let viewModel = try await makeCashFlow()
        await viewModel.widget.load(dataVersion: 0)
        let month = viewModel.widget.filter.month

        viewModel.widget.shiftMonth(by: -1)
        await viewModel.widget.load(dataVersion: 0)

        #expect(repository.dailyCashFlowCalls.map(\.month) == [month, month.adding(months: -1)])
    }

    @Test func failureCanBeRetried() async throws {
        let viewModel = try await makeCashFlow()
        repository.setWidgetFails(true)

        await viewModel.widget.load(dataVersion: 0)
        #expect(viewModel.widget.state == .failed)

        repository.setWidgetFails(false)
        await viewModel.widget.refresh()
        #expect(viewModel.widget.state == .loaded(usdDays))
    }

    @Test func recentTransactionsAskForThreeInTheCurrency() async throws {
        preferences.primaryCurrencyCode = "EUR"
        let transactions = Array(DemoData.transactions(inMonthOf: .now).prefix(5))
        repository.setRecentTransactions(transactions, currencyCode: "EUR")
        let widget = WalletWidgetViewModel<[Transaction]>.recentTransactions(
            repository: repository, referenceData: try await referenceData(), preferences: preferences
        )

        await widget.load(dataVersion: 0)

        #expect(widget.state.value?.count == min(3, transactions.count))
        #expect(repository.recentTransactionsCalls == [.init(month: nil, currencyCode: "EUR")])
    }

    // MARK: Incomes on / off (ACC-03)

    @Test func withIncomesOffAMonthOfIncomesOnlyIsEmpty() async throws {
        let viewModel = try await makeCashFlow()
        let days = [DailyCashFlow(day: .now, income: 3200, expense: 0)]

        #expect(!viewModel.isEmpty(days))
        viewModel.includesIncome = false
        #expect(viewModel.isEmpty(days))
    }

    // MARK: Statistics (ACC-05)

    @Test func statisticsShowTheKindsGroupsOnly() async throws {
        let viewModel = WalletStatisticsViewModel(
            repository: repository, referenceData: try await referenceData(), preferences: preferences
        )
        let groups = [
            GroupAmounts(id: 1, name: "Food", income: 0, expense: 195),
            GroupAmounts(id: 5, name: "Salary", income: 3200, expense: 0),
            GroupAmounts(id: 6, name: "Refunds", income: 20, expense: 5),
        ]

        #expect(viewModel.summary(of: groups).slices.map(\.name) == ["Food", "Refunds"])
        #expect(viewModel.summary(of: groups).total == 200)

        viewModel.kind = .income
        #expect(viewModel.summary(of: groups).slices.map(\.name) == ["Salary", "Refunds"])
        #expect(viewModel.summary(of: groups).total == 3220)
    }

    @Test func moreThanSevenGroupsShowSixAndOther() async throws {
        let viewModel = WalletStatisticsViewModel(
            repository: repository, referenceData: try await referenceData(), preferences: preferences
        )
        let groups = (1...8).map { GroupAmounts(id: Int64($0), name: "G\($0)", income: 0, expense: Decimal($0 * 10)) }

        let summary = viewModel.summary(of: groups)

        #expect(summary.slices.count == 7)
        #expect(summary.slices.last == ChartSlice(id: 6, name: nil, amount: 30)) // 20 + 10
        let shares = summary.slices.reduce(Decimal(0)) { $0 + summary.share(of: $1) }
        #expect(abs(shares - 1) < Decimal(string: "0.000001")!)
    }
}
