import Foundation
import Observation

/// A Budget screen (`BUD-01…17`): the month by group, or one group by category. Three cards load in parallel, each
/// with its own state, like the Dashboard's (`GEN-23…25`).
@Observable
final class BudgetViewModel {
    nonisolated enum Card: CaseIterable, Sendable {
        case budgets, totals, expenses
    }

    /// What the cards on screen were loaded for.
    private struct LoadKey: Equatable {
        let query: BudgetQuery
        let dataVersion: Int
    }

    private(set) var budgets: CardState<[BudgetItem]> = .loading
    private(set) var totals: CardState<BudgetTotals> = .loading
    private(set) var expenses: CardState<[MonthlyExpense]> = .loading

    let filter: BudgetFilter
    /// `nil` for the month's screen, the group's id for a group's (`BUD-17`).
    let groupID: Int64?

    private let repository: any BudgetRepository
    private let referenceData: ReferenceDataStore
    private let preferences: DevicePreferences
    @ObservationIgnored private var loadedKey: LoadKey?

    init(
        repository: any BudgetRepository,
        referenceData: ReferenceDataStore,
        preferences: DevicePreferences,
        filter: BudgetFilter,
        groupID: Int64? = nil
    ) {
        self.repository = repository
        self.referenceData = referenceData
        self.preferences = preferences
        self.filter = filter
        self.groupID = groupID
    }

    // MARK: Filters (BUD-11)

    /// The currencies of the user's accounts, alphabetically (`GEN-11`).
    var currencyCodes: [String] {
        referenceData.accountCurrencyCodes.sorted()
    }

    /// The currency picked here; until then the primary currency (`DASH-01`). One no account has any more falls back
    /// the same way.
    var currencyCode: String? {
        let codes = currencyCodes
        if let code = filter.currencyCode, codes.contains(code) { return code }
        if let code = preferences.primaryCurrencyCode, codes.contains(code) { return code }
        return codes.first
    }

    var query: BudgetQuery? {
        currencyCode.map { BudgetQuery(month: filter.month, currencyCode: $0, groupID: groupID) }
    }

    func selectCurrency(_ code: String) {
        filter.currencyCode = code
    }

    func shiftMonth(by months: Int) {
        filter.shiftMonth(by: months)
    }

    /// The group cards that pass the status and group filters; a group's screen has no such filters (`BUD-17`).
    var visibleBudgets: [BudgetItem] {
        let items = budgets.value ?? []
        return groupID == nil ? items.filter(filter.matches) : items
    }

    /// The groups the group filter offers: those of the month's cards, by name.
    var groupOptions: [BudgetItem] {
        (budgets.value ?? []).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    /// "Edit budget" when the month has a plan in the currency, "Add budget" otherwise (`BUD-15`).
    var hasPlan: Bool {
        totals.value?.hasPlan ?? false
    }

    // MARK: Loading

    /// Brings the cards up to date. Another month or currency shows skeletons, since the figures on screen are
    /// wrong for it; new data keeps them until the new ones arrive (`GEN-26`); nothing changed loads nothing.
    func load(dataVersion: Int) async {
        guard let query else {
            // Only without accounts, which the main app never is (`NAV-07`).
            budgets = .failed
            totals = .failed
            expenses = .failed
            return
        }
        // The first load fixes the currency for the session (`DASH-01`).
        if filter.currencyCode != query.currencyCode {
            filter.currencyCode = query.currencyCode
        }

        let key = LoadKey(query: query, dataVersion: dataVersion)
        guard key != loadedKey else { return }
        if loadedKey?.query != query {
            budgets = .loading
            totals = .loading
            expenses = .loading
        }
        loadedKey = key
        await reload(Card.allCases, query: query)
        // Interrupted, e.g. by leaving the tab: the next appearance loads again rather than keep a skeleton.
        if Task.isCancelled, loadedKey == key {
            loadedKey = nil
        }
    }

    /// Pull to refresh: every card, keeping the current figures until the new ones arrive.
    func refresh() async {
        guard let query else { return }
        await reload(Card.allCases, query: query)
    }

    /// "Try again" on one failed card (`GEN-25`).
    func retry(_ card: Card) async {
        guard let query else { return }
        await reload([card], query: query)
    }

    private func reload(_ cards: [Card], query: BudgetQuery) async {
        await withDiscardingTaskGroup { group in
            for card in cards {
                group.addTask { await self.load(card, query: query) }
            }
        }
    }

    private func load(_ card: Card, query: BudgetQuery) async {
        switch card {
        case .budgets: await load(\.budgets, query: query) { try await self.repository.budgets(query) }
        case .totals: await load(\.totals, query: query) { try await self.repository.totals(query) }
        case .expenses: await load(\.expenses, query: query) { try await self.repository.expenses(query) }
        }
    }

    /// Only a failed card shows loading again; a response for a month or currency no longer selected is dropped.
    private func load<Value>(
        _ keyPath: ReferenceWritableKeyPath<BudgetViewModel, CardState<Value>>,
        query: BudgetQuery,
        fetch: () async throws -> Value
    ) async {
        if case .failed = self[keyPath: keyPath] {
            self[keyPath: keyPath] = .loading
        }
        do {
            let value = try await fetch()
            guard !Task.isCancelled, self.query == query else { return }
            self[keyPath: keyPath] = .loaded(value)
        } catch {
            guard !Task.isCancelled, self.query == query else { return }
            self[keyPath: keyPath] = .failed
        }
    }
}
