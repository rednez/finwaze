import Foundation
import Observation

/// The Goals screen (`GOAL-10…17`): the filtered goals with "Total goals", and the savings overview for one of their
/// currencies. The list and the overview load with their own states (`GEN-23…25`).
@Observable
final class GoalsViewModel {
    /// What the list on screen was loaded for.
    private struct LoadKey: Equatable {
        let query: GoalsQuery
        let dataVersion: Int
    }

    /// What the overview on screen was loaded for.
    private struct OverviewKey: Equatable {
        let year: Int
        let currencyCode: String
    }

    /// The year of the filter, the current one at first (`GOAL-10`).
    var year: Int
    /// `nil` for every status (`GOAL-10`).
    var status: SavingsGoalStatus?

    /// A confirmation after a deposit, a withdrawal or a goal's screen closing (`GOAL-13`, `GOAL-14`).
    var banner: LocalizedStringResource?
    private(set) var goals: CardState<[SavingsGoal]> = .loading
    private(set) var overview: CardState<[MonthlySavings]> = .loading

    private let repository: any GoalsRepository
    private let currentYear: Int
    /// The overview's currency picked here; kept while the list still has goals in it (`GOAL-16`).
    private var chosenOverviewCurrency: String?
    @ObservationIgnored private var loadedKey: LoadKey?
    @ObservationIgnored private var overviewKey: OverviewKey?

    init(repository: any GoalsRepository, now: Date = .now, calendar: Calendar = .current) {
        self.repository = repository
        currentYear = calendar.component(.year, from: now)
        year = currentYear
    }

    var query: GoalsQuery {
        GoalsQuery(year: year, status: status)
    }

    func shiftYear(by years: Int) {
        year += years
    }

    /// Whether the filters may hide goals, so an empty list does not mean there are none (`GOAL-17`).
    var narrowsGoals: Bool {
        status != nil || year != currentYear
    }

    /// "Total goals" of the goals on screen (`GOAL-15`).
    var summary: GoalsSummary? {
        goals.value.map(GoalsSummary.init)
    }

    // MARK: Savings overview (GOAL-16)

    /// The currencies of the goals on screen, newest goal's first, without repeats.
    var overviewCurrencyCodes: [String] {
        var seen = Set<String>()
        return (goals.value ?? []).map(\.currencyCode).filter { seen.insert($0).inserted }
    }

    /// The currency picked here while it is still among the goals', else the first.
    var overviewCurrencyCode: String? {
        let codes = overviewCurrencyCodes
        if let code = chosenOverviewCurrency, codes.contains(code) { return code }
        return codes.first
    }

    func selectOverviewCurrency(_ code: String) async {
        chosenOverviewCurrency = code
        await loadOverview(force: false)
    }

    // MARK: Loading

    /// Brings the screen up to date. Other filters show skeletons, since the goals on screen are wrong for them; new
    /// data keeps them until the new ones arrive (`GEN-26`); nothing changed loads nothing.
    func load(dataVersion: Int) async {
        let key = LoadKey(query: query, dataVersion: dataVersion)
        guard key != loadedKey else { return }
        if loadedKey?.query != key.query {
            goals = .loading
        }
        loadedKey = key
        await loadGoals(key.query)
        await loadOverview(force: true)
        // Interrupted, e.g. by leaving the screen: the next appearance loads again rather than keep a skeleton.
        if Task.isCancelled, loadedKey == key {
            loadedKey = nil
        }
    }

    /// Pull to refresh, keeping the current figures until the new ones arrive.
    func refresh() async {
        await loadGoals(query)
        await loadOverview(force: true)
    }

    /// "Try again" on the list (`GEN-25`).
    func retryGoals() async {
        goals = .loading
        await loadGoals(query)
        await loadOverview(force: true)
    }

    /// "Try again" on the overview (`GEN-25`).
    func retryOverview() async {
        await loadOverview(force: true)
    }

    private func loadGoals(_ query: GoalsQuery) async {
        do {
            let value = try await repository.goals(query)
            guard !Task.isCancelled, self.query == query else { return }
            goals = .loaded(value)
        } catch {
            guard !Task.isCancelled, self.query == query else { return }
            goals = .failed
        }
    }

    /// The overview for the filter's year and the chosen currency. Without goals there is nothing to show; the same
    /// year and currency load again only when `force`d, e.g. after a deposit.
    private func loadOverview(force: Bool) async {
        guard let currencyCode = overviewCurrencyCode else {
            overviewKey = nil
            return
        }
        let key = OverviewKey(year: year, currencyCode: currencyCode)
        guard force || key != overviewKey else { return }
        if overviewKey != key || overview == .failed {
            overview = .loading
        }
        overviewKey = key
        do {
            let value = try await repository.savingsOverview(year: key.year, currencyCode: key.currencyCode)
            guard !Task.isCancelled, overviewKey == key else { return }
            overview = .loaded(value)
        } catch {
            guard !Task.isCancelled, overviewKey == key else { return }
            overview = .failed
        }
    }
}
