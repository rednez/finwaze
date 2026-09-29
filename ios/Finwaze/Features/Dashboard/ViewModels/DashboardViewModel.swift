import Foundation
import Observation

/// The Dashboard (`DASH-01…08`): the primary currency and five cards that load in parallel, each with its own state.
@Observable
final class DashboardViewModel {
    nonisolated enum Card: CaseIterable, Sendable {
        case totals, cashFlow, budget, recentTransactions, goals
    }

    /// The cash flow chart's period (`DASH-04`).
    static let cashFlowMonths = 6
    /// How many recent transactions and goals the cards show (`DASH-06`, `DASH-07`).
    static let recentLimit = 3

    private let totalsCard: CardLoader<String, DashboardTotals>
    private let cashFlowCard: CardLoader<String, [MonthlyCashFlow]>
    private let budgetCard: CardLoader<String, SliceSummary>
    /// Not in a currency: their only key is the data version (`CardLoader`), so a new currency leaves them be.
    private let recentTransactionsCard: CardLoader<Bool, [Transaction]>
    private let goalsCard: CardLoader<Bool, [SavingsGoal]>

    private let preferences: DevicePreferences

    init(repository: any DashboardRepository, preferences: DevicePreferences) {
        self.preferences = preferences

        let currencyCode = { preferences.primaryCurrencyCode }
        totalsCard = CardLoader(key: currencyCode) { try await repository.totals(currencyCode: $0) }
        cashFlowCard = CardLoader(key: currencyCode) {
            try await repository.monthlyCashFlow(currencyCode: $0, months: Self.cashFlowMonths)
        }
        budgetCard = CardLoader(key: currencyCode) {
            SliceSummary(budgets: try await repository.currentMonthBudgets(currencyCode: $0))
        }
        recentTransactionsCard = CardLoader(key: { true }) { _ in
            try await repository.recentTransactions(limit: Self.recentLimit)
        }
        goalsCard = CardLoader(key: { true }) { _ in try await repository.recentGoals(limit: Self.recentLimit) }
    }

    var totals: CardState<DashboardTotals> { totalsCard.state }
    var cashFlow: CardState<[MonthlyCashFlow]> { cashFlowCard.state }
    var budget: CardState<SliceSummary> { budgetCard.state }
    var recentTransactions: CardState<[Transaction]> { recentTransactionsCard.state }
    var goals: CardState<[SavingsGoal]> { goalsCard.state }

    /// The primary currency, remembered on the device and chosen in the navigation bar (`DASH-01`, `GEN-17`,
    /// `PrimaryCurrencyMenu`); when it changes, the view calls `load(dataVersion:)`, which reloads the cards in it.
    var currencyCode: String? {
        preferences.primaryCurrencyCode
    }

    /// Brings the cards up to date: every card after a change to the data (`GEN-26`), only the currency's cards after
    /// a change of currency (`DASH-01`), nothing when both are as loaded — e.g. when coming back to the tab.
    func load(dataVersion: Int) async {
        async let totals: Void = totalsCard.load(dataVersion: dataVersion)
        async let cashFlow: Void = cashFlowCard.load(dataVersion: dataVersion)
        async let budget: Void = budgetCard.load(dataVersion: dataVersion)
        async let recentTransactions: Void = recentTransactionsCard.load(dataVersion: dataVersion)
        async let goals: Void = goalsCard.load(dataVersion: dataVersion)
        _ = await (totals, cashFlow, budget, recentTransactions, goals)
    }

    /// Pull to refresh: every card, keeping the current figures until the new ones arrive.
    func refresh() async {
        async let totals: Void = totalsCard.refresh()
        async let cashFlow: Void = cashFlowCard.refresh()
        async let budget: Void = budgetCard.refresh()
        async let recentTransactions: Void = recentTransactionsCard.refresh()
        async let goals: Void = goalsCard.refresh()
        _ = await (totals, cashFlow, budget, recentTransactions, goals)
    }

    /// "Try again" on one failed card (`DASH-08`).
    func retry(_ card: Card) async {
        switch card {
        case .totals: await totalsCard.refresh()
        case .cashFlow: await cashFlowCard.refresh()
        case .budget: await budgetCard.refresh()
        case .recentTransactions: await recentTransactionsCard.refresh()
        case .goals: await goalsCard.refresh()
        }
    }
}
