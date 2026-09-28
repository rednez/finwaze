import Foundation
import Testing
@testable import Finwaze

@MainActor
struct GoalsViewModelTests {
    private let repository = FakeGoalsRepository()
    private let now = Date(timeIntervalSince1970: 1_790_500_500) // 27 September 2026
    private let usdGoal = SavingsGoal.fixture(id: 1, currencyCode: "USD", status: .inProgress)
    private let eurGoal = SavingsGoal.fixture(id: 2, currencyCode: "EUR", status: .notStarted, saved: 0)
    private let doneGoal = SavingsGoal.fixture(id: 3, currencyCode: "USD", status: .done, saved: 1000)

    private func makeViewModel() -> GoalsViewModel {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Kyiv")!
        repository.setGoals([usdGoal, eurGoal, doneGoal])
        return GoalsViewModel(repository: repository, now: now, calendar: calendar)
    }

    @Test func loadsTheCurrentYearWithEveryStatus() async {
        let viewModel = makeViewModel()

        await viewModel.load(dataVersion: 0)

        #expect(repository.queries == [GoalsQuery(year: 2026, status: nil)])
        #expect(viewModel.goals == .loaded([usdGoal, eurGoal, doneGoal]))
        #expect(!viewModel.narrowsGoals)
    }

    @Test func filtersGoToTheServer() async {
        let viewModel = makeViewModel()
        await viewModel.load(dataVersion: 0)

        viewModel.shiftYear(by: 1)
        viewModel.status = .done
        await viewModel.load(dataVersion: 0)

        #expect(repository.queries.last == GoalsQuery(year: 2027, status: .done))
        #expect(viewModel.goals == .loaded([doneGoal]))
        #expect(viewModel.narrowsGoals)
    }

    @Test func nothingChangedLoadsNothing() async {
        let viewModel = makeViewModel()
        await viewModel.load(dataVersion: 0)

        await viewModel.load(dataVersion: 0)
        #expect(repository.queries.count == 1)

        await viewModel.load(dataVersion: 1)
        #expect(repository.queries.count == 2)
    }

    @Test func summaryCountsTheGoalsOnScreen() async {
        let viewModel = makeViewModel()

        await viewModel.load(dataVersion: 0)

        #expect(viewModel.summary?.total == 3)
        #expect(viewModel.summary?.count(.inProgress) == 1)
        #expect(viewModel.summary?.count(.done) == 1)
    }

    @Test func failedListCanBeRetried() async {
        let viewModel = makeViewModel()
        repository.setFails(.goals)
        await viewModel.load(dataVersion: 0)
        #expect(viewModel.goals == .failed)

        repository.setFails(.goals, false)
        await viewModel.retryGoals()

        #expect(viewModel.goals.value?.count == 3)
    }

    // MARK: Savings overview (GOAL-16)

    @Test func overviewUsesTheNewestGoalsCurrencyAndTheFilterYear() async {
        let viewModel = makeViewModel()
        let months = [MonthlySavings(month: YearMonth(year: 2026, month: 1), currentYear: 100, previousYear: -20)]
        repository.setOverview(months, for: "USD")

        await viewModel.load(dataVersion: 0)

        #expect(viewModel.overviewCurrencyCodes == ["USD", "EUR"])
        #expect(viewModel.overviewCurrencyCode == "USD")
        #expect(repository.overviewRequests.last?.year == 2026)
        #expect(viewModel.overview == .loaded(months))
    }

    @Test func overviewCurrencyCanBeChosen() async {
        let viewModel = makeViewModel()
        await viewModel.load(dataVersion: 0)

        await viewModel.selectOverviewCurrency("EUR")

        #expect(viewModel.overviewCurrencyCode == "EUR")
        #expect(repository.overviewRequests.last?.currencyCode == "EUR")
    }

    @Test func chosenCurrencyFallsBackWhenNoGoalHasIt() async {
        let viewModel = makeViewModel()
        await viewModel.load(dataVersion: 0)
        await viewModel.selectOverviewCurrency("EUR")

        viewModel.status = .done
        await viewModel.load(dataVersion: 0)

        #expect(viewModel.overviewCurrencyCode == "USD")
        #expect(repository.overviewRequests.last?.currencyCode == "USD")
    }

    @Test func noGoalsNoOverview() async {
        let viewModel = makeViewModel()
        repository.setGoals([])

        await viewModel.load(dataVersion: 0)

        #expect(viewModel.overviewCurrencyCode == nil)
        #expect(repository.overviewRequests.isEmpty)
    }
}
