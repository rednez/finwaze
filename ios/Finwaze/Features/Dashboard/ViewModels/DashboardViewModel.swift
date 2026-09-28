import Foundation
import Observation

/// The Dashboard (`DASH-01…08`): the primary currency and five cards that load in parallel, each with its own state.
@Observable
final class DashboardViewModel {
    nonisolated enum Card: CaseIterable, Sendable {
        case totals, cashFlow, budget, recentTransactions, goals

        /// Shown in the primary currency, so reloaded when it changes (`DASH-01`).
        var followsCurrency: Bool {
            switch self {
            case .totals, .cashFlow, .budget: true
            case .recentTransactions, .goals: false
            }
        }
    }

    /// The cash flow chart's period (`DASH-04`).
    static let cashFlowMonths = 12
    /// How many recent transactions and goals the cards show (`DASH-06`, `DASH-07`).
    static let recentLimit = 3

    private(set) var totals: CardState<DashboardTotals> = .loading
    private(set) var cashFlow: CardState<[MonthlyCashFlow]> = .loading
    private(set) var budget: CardState<SliceSummary> = .loading
    private(set) var recentTransactions: CardState<[Transaction]> = .loading
    private(set) var goals: CardState<[SavingsGoal]> = .loading

    private let repository: any DashboardRepository
    private let referenceData: ReferenceDataStore
    private let preferences: DevicePreferences
    /// What the cards on screen were loaded for; `load(dataVersion:)` reloads only what changed.
    @ObservationIgnored private var loadedDataVersion: Int?
    @ObservationIgnored private var loadedCurrencyCode: String?

    init(repository: any DashboardRepository, referenceData: ReferenceDataStore, preferences: DevicePreferences) {
        self.repository = repository
        self.referenceData = referenceData
        self.preferences = preferences
    }

    /// The currencies of the user's accounts, alphabetically (`GEN-11`).
    var currencyCodes: [String] {
        referenceData.accountCurrencyCodes.sorted()
    }

    /// The primary currency, remembered on the device (`DASH-01`, `GEN-17`).
    var currencyCode: String? {
        preferences.primaryCurrencyCode
    }

    /// Makes `code` the primary currency; the view then calls `load(dataVersion:)`, which reloads the cards in it.
    func selectCurrency(_ code: String) {
        preferences.primaryCurrencyCode = code
    }

    /// Brings the cards up to date: every card after a change to the data (`GEN-26`), only the currency's cards after
    /// a change of currency (`DASH-01`), nothing when both are as loaded — e.g. when coming back to the tab.
    func load(dataVersion: Int) async {
        let code = currencyCode
        if loadedDataVersion != dataVersion {
            loadedDataVersion = dataVersion
            loadedCurrencyCode = code
            await reload(Card.allCases)
        } else if loadedCurrencyCode != code {
            loadedCurrencyCode = code
            // The figures on screen are in the previous currency: better a skeleton than wrong amounts.
            resetToLoading(Card.allCases.filter(\.followsCurrency))
            await reload(Card.allCases.filter(\.followsCurrency))
        }
    }

    /// Pull to refresh: every card, keeping the current figures until the new ones arrive.
    func refresh() async {
        await reload(Card.allCases)
    }

    /// "Try again" on one failed card (`DASH-08`).
    func retry(_ card: Card) async {
        await reload([card])
    }

    private func reload(_ cards: [Card]) async {
        await withDiscardingTaskGroup { group in
            for card in cards {
                group.addTask { await self.load(card) }
            }
        }
    }

    private func load(_ card: Card) async {
        switch card {
        case .totals:
            await loadInCurrency(\.totals) { try await self.repository.totals(currencyCode: $0) }
        case .cashFlow:
            await loadInCurrency(\.cashFlow) {
                try await self.repository.monthlyCashFlow(currencyCode: $0, months: Self.cashFlowMonths)
            }
        case .budget:
            await loadInCurrency(\.budget) { SliceSummary(budgets: try await self.repository.currentMonthBudgets(currencyCode: $0)) }
        case .recentTransactions:
            await load(\.recentTransactions) { try await self.repository.recentTransactions(limit: Self.recentLimit) }
        case .goals:
            await load(\.goals) { try await self.repository.recentGoals(limit: Self.recentLimit) }
        }
    }

    /// Loads a card in the primary currency; a response for a currency no longer selected is dropped.
    private func loadInCurrency<Value>(
        _ keyPath: ReferenceWritableKeyPath<DashboardViewModel, CardState<Value>>,
        fetch: @escaping (String) async throws -> Value
    ) async {
        guard let code = currencyCode else {
            // Only without accounts, which the main app never is (`NAV-07`).
            self[keyPath: keyPath] = .failed
            return
        }
        await load(keyPath, isCurrent: { self.currencyCode == code }, fetch: { try await fetch(code) })
    }

    /// A reload keeps the card's figures until the new ones arrive (`GEN-26`); only a failed card shows loading again.
    private func load<Value>(
        _ keyPath: ReferenceWritableKeyPath<DashboardViewModel, CardState<Value>>,
        isCurrent: () -> Bool = { true },
        fetch: () async throws -> Value
    ) async {
        if case .failed = self[keyPath: keyPath] {
            self[keyPath: keyPath] = .loading
        }
        do {
            let value = try await fetch()
            guard !Task.isCancelled, isCurrent() else { return }
            self[keyPath: keyPath] = .loaded(value)
        } catch {
            guard !Task.isCancelled, isCurrent() else { return }
            self[keyPath: keyPath] = .failed
        }
    }

    private func resetToLoading(_ cards: [Card]) {
        for card in cards {
            switch card {
            case .totals: totals = .loading
            case .cashFlow: cashFlow = .loading
            case .budget: budget = .loading
            case .recentTransactions: recentTransactions = .loading
            case .goals: goals = .loading
            }
        }
    }
}
