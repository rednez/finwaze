import Foundation
import Observation

/// A Budget screen (`BUD-01…17`): the month by group, or one group by category. Three cards load in parallel, each
/// with its own state, like the Dashboard's (`GEN-23…25`).
@Observable
final class BudgetViewModel {
    nonisolated enum Card: Sendable {
        case budgets, totals, expenses
    }

    private let budgetsCard: CardLoader<BudgetQuery, [BudgetItem]>
    private let totalsCard: CardLoader<BudgetQuery, BudgetTotals>
    private let expensesCard: CardLoader<BudgetQuery, [MonthlyExpense]>

    let filter: BudgetFilter
    /// `nil` for the month's screen, the group's id for a group's (`BUD-17`).
    let groupID: Int64?

    private let referenceData: ReferenceDataStore
    private let preferences: DevicePreferences

    init(
        repository: any BudgetRepository,
        referenceData: ReferenceDataStore,
        preferences: DevicePreferences,
        filter: BudgetFilter,
        groupID: Int64? = nil
    ) {
        self.referenceData = referenceData
        self.preferences = preferences
        self.filter = filter
        self.groupID = groupID

        let query = { Self.query(filter: filter, referenceData: referenceData, preferences: preferences, groupID: groupID) }
        budgetsCard = CardLoader(key: query) { try await repository.budgets($0) }
        totalsCard = CardLoader(key: query) { try await repository.totals($0) }
        expensesCard = CardLoader(key: query) { try await repository.expenses($0) }
    }

    var budgets: CardState<[BudgetItem]> { budgetsCard.state }
    var totals: CardState<BudgetTotals> { totalsCard.state }
    var expenses: CardState<[MonthlyExpense]> { expensesCard.state }

    // MARK: Filters (BUD-11)

    /// The currencies of the user's accounts, alphabetically (`GEN-11`).
    var currencyCodes: [String] {
        referenceData.sortedAccountCurrencyCodes
    }

    /// The currency picked here; until then the primary currency (`DASH-01`). One no account has any more falls back
    /// the same way.
    var currencyCode: String? {
        query?.currencyCode
    }

    var query: BudgetQuery? {
        budgetsCard.key
    }

    private static func query(
        filter: BudgetFilter,
        referenceData: ReferenceDataStore,
        preferences: DevicePreferences,
        groupID: Int64?
    ) -> BudgetQuery? {
        CurrencySelection.currencyCode(
            picked: filter.currencyCode,
            among: referenceData.sortedAccountCurrencyCodes,
            primary: preferences.primaryCurrencyCode
        )
        .map { BudgetQuery(month: filter.month, currencyCode: $0, groupID: groupID) }
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

    /// Brings the cards up to date; each loads only when what it shows changed (see `CardLoader`).
    func load(dataVersion: Int) async {
        // The first load fixes the currency for the session (`DASH-01`).
        if let currencyCode, filter.currencyCode != currencyCode {
            filter.currencyCode = currencyCode
        }
        async let budgets: Void = budgetsCard.load(dataVersion: dataVersion)
        async let totals: Void = totalsCard.load(dataVersion: dataVersion)
        async let expenses: Void = expensesCard.load(dataVersion: dataVersion)
        _ = await (budgets, totals, expenses)
    }

    /// Pull to refresh: every card, keeping the current figures until the new ones arrive.
    func refresh() async {
        async let budgets: Void = budgetsCard.refresh()
        async let totals: Void = totalsCard.refresh()
        async let expenses: Void = expensesCard.refresh()
        _ = await (budgets, totals, expenses)
    }

    /// "Try again" on one failed card (`GEN-25`).
    func retry(_ card: Card) async {
        switch card {
        case .budgets: await budgetsCard.refresh()
        case .totals: await totalsCard.refresh()
        case .expenses: await expensesCard.refresh()
        }
    }
}
