import Foundation
import Observation

/// Analytics (`ANL-01…06`): the filters kept for the session and four cards that load on their own, so one failing
/// leaves the others be (`GEN-25`). Figures count the amounts charged to accounts in the chosen currency (`ANL-06`).
@Observable
final class AnalyticsViewModel {
    /// What "Monthly overview" draws; switching only changes the lines, so nothing reloads (`ANL-03`).
    enum OverviewMetric: CaseIterable, Hashable {
        case balance, income, expense
    }

    /// What "Statistics" shows; switching only changes the ring, so nothing reloads (`ANL-05`).
    enum StatisticsMode: CaseIterable, Hashable {
        case expense, income, budget
    }

    let filter: AnalyticsFilter
    /// The three summary cards (`ANL-02`).
    let summary: CardLoader<AnalyticsQuery, AnalyticsSummary>
    /// "Monthly overview": the month and the one before (`ANL-03`).
    let overview: CardLoader<AnalyticsQuery, MonthlyOverview>
    /// "Statistics": amounts and the budget by group (`ANL-05`).
    let statistics: CardLoader<AnalyticsQuery, GroupStatistics>
    /// "Budgets vs Expenses": by year and currency only, so the month and the accounts never reload it (`ANL-04`).
    let budgetsVsExpenses: CardLoader<AnalyticsYearKey, [MonthlyBudgetExpense]>

    var overviewMetric: OverviewMetric = .balance
    var statisticsMode: StatisticsMode = .expense

    private let referenceData: ReferenceDataStore
    private let preferences: DevicePreferences

    init(
        repository: any AnalyticsRepository,
        budgetRepository: any BudgetRepository,
        referenceData: ReferenceDataStore,
        preferences: DevicePreferences,
        filter: AnalyticsFilter
    ) {
        self.referenceData = referenceData
        self.preferences = preferences
        self.filter = filter

        let selection = Selection(filter: filter, referenceData: referenceData, preferences: preferences)
        summary = CardLoader(key: selection.query) { try await repository.summary($0) }
        overview = CardLoader(key: selection.query) { query in
            let previousQuery = AnalyticsQuery(
                month: query.month.adding(months: -1),
                currencyCode: query.currencyCode,
                accountIDs: query.accountIDs
            )
            async let current = repository.dailyOverview(query)
            async let previous = repository.dailyOverview(previousQuery)
            return try await MonthlyOverview(current: current, previous: previous)
        }
        statistics = CardLoader(key: selection.query) { query in
            async let amounts = repository.amountsByGroup(query)
            // The budget knows no accounts (`ANL-05`).
            async let budgets = budgetRepository.budgets(
                BudgetQuery(month: query.month, currencyCode: query.currencyCode, groupID: nil)
            )
            return try await GroupStatistics(amounts: amounts, budgets: budgets)
        }
        budgetsVsExpenses = CardLoader(key: selection.yearKey) {
            try await repository.yearlyBudgetsVsExpenses(year: $0.year, currencyCode: $0.currencyCode)
        }
    }

    // MARK: Filters (ANL-01)

    /// The currencies of the user's accounts, alphabetically (`GEN-11`).
    var currencyCodes: [String] {
        Selection.currencyCodes(referenceData)
    }

    /// The currency picked here; until then the primary currency (`DASH-01`).
    var currencyCode: String? {
        selection.currencyCode
    }

    /// The currency's regular accounts, by name, like the web — goal accounts are not offered.
    var accounts: [Account] {
        selection.accounts
    }

    /// The picked accounts still in the currency; empty for all of them.
    var selectedAccountIDs: Set<Int64> {
        selection.accountIDs
    }

    var query: AnalyticsQuery? {
        summary.key
    }

    var yearKey: AnalyticsYearKey? {
        budgetsVsExpenses.key
    }

    func shiftMonth(by months: Int) {
        filter.shiftMonth(by: months)
    }

    func shiftBudgetYear(by years: Int) {
        filter.shiftBudgetYear(by: years)
    }

    func selectCurrency(_ code: String) {
        filter.selectCurrency(code)
    }

    func setAccount(_ id: Int64, isSelected: Bool) {
        // Starting from "all", ticking one account picks just it; unticking the last one is "all" again.
        filter.setAccount(id, isSelected: isSelected)
    }

    func selectAllAccounts() {
        filter.selectAllAccounts()
    }

    // MARK: Loading (GEN-26)

    /// Brings every card up to date; each loads only when what it shows changed (see `CardLoader`).
    func load(dataVersion: Int) async {
        async let summary: Void = summary.load(dataVersion: dataVersion)
        async let overview: Void = overview.load(dataVersion: dataVersion)
        async let statistics: Void = statistics.load(dataVersion: dataVersion)
        async let budgets: Void = budgetsVsExpenses.load(dataVersion: dataVersion)
        _ = await (summary, overview, statistics, budgets)
    }

    /// Pull to refresh: every card, keeping the figures until the new ones arrive.
    func refresh() async {
        async let summary: Void = summary.refresh()
        async let overview: Void = overview.refresh()
        async let statistics: Void = statistics.refresh()
        async let budgets: Void = budgetsVsExpenses.refresh()
        _ = await (summary, overview, statistics, budgets)
    }

    // MARK: Cards

    /// "$150.00 more than last month" under a summary card (`ANL-02`).
    func comparison(_ kind: SummaryKind, in summary: AnalyticsSummary) -> SummaryComparison {
        SummaryComparison(current: kind.current(in: summary), previous: kind.previous(in: summary))
    }

    /// The ring of "Statistics" in the current mode: groups with any amount, the six largest and "Other categories"
    /// beyond seven, like the Wallet and the Dashboard (`ANL-05`).
    func statisticsSummary(of statistics: GroupStatistics) -> SliceSummary {
        switch statisticsMode {
        case .expense:
            SliceSummary(statistics.amounts.compactMap { $0.expense > 0 ? NamedAmount(name: $0.name, amount: $0.expense) : nil })
        case .income:
            SliceSummary(statistics.amounts.compactMap { $0.income > 0 ? NamedAmount(name: $0.name, amount: $0.income) : nil })
        case .budget:
            SliceSummary(statistics.budgets.compactMap { $0.planned > 0 ? NamedAmount(name: $0.name, amount: $0.planned) : nil })
        }
    }

    private var selection: Selection {
        Selection(filter: filter, referenceData: referenceData, preferences: preferences)
    }
}

/// The filters resolved against the user's accounts; the cards' keys read it on every load, so a change of primary
/// currency or accounts applies at once.
private struct Selection {
    let filter: AnalyticsFilter
    let referenceData: ReferenceDataStore
    let preferences: DevicePreferences

    static func currencyCodes(_ referenceData: ReferenceDataStore) -> [String] {
        referenceData.accountCurrencyCodes.sorted()
    }

    var currencyCode: String? {
        filter.currencyCode(among: Self.currencyCodes(referenceData), primary: preferences.primaryCurrencyCode)
    }

    var accounts: [Account] {
        guard let currencyCode else { return [] }
        return referenceData.accounts
            .filter { $0.currencyCode == currencyCode }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var accountIDs: Set<Int64> {
        filter.selectedAccountIDs(among: accounts)
    }

    func query() -> AnalyticsQuery? {
        currencyCode.map { AnalyticsQuery(month: filter.month, currencyCode: $0, accountIDs: accountIDs) }
    }

    func yearKey() -> AnalyticsYearKey? {
        currencyCode.map { AnalyticsYearKey(year: filter.budgetYear, currencyCode: $0) }
    }
}

extension SummaryKind {
    func current(in summary: AnalyticsSummary) -> Decimal {
        switch self {
        case .balance: summary.totalBalance
        case .income: summary.monthlyIncome
        case .expenses: summary.monthlyExpense
        }
    }

    func previous(in summary: AnalyticsSummary) -> Decimal {
        switch self {
        case .balance: summary.previousTotalBalance
        case .income: summary.previousMonthlyIncome
        case .expenses: summary.previousMonthlyExpense
        }
    }

    /// The month's transactions behind the figure; for the balance both kinds, like the web (`ANL-02`).
    func transactionCount(in summary: AnalyticsSummary) -> Int {
        switch self {
        case .balance: summary.incomeTransactionCount + summary.expenseTransactionCount
        case .income: summary.incomeTransactionCount
        case .expenses: summary.expenseTransactionCount
        }
    }

    /// The month's groups behind the figure; for the balance a group with both incomes and expenses counts twice,
    /// like the web (`ANL-02`).
    func groupsCount(in summary: AnalyticsSummary) -> Int {
        switch self {
        case .balance: summary.incomeGroupsCount + summary.expenseGroupsCount
        case .income: summary.incomeGroupsCount
        case .expenses: summary.expenseGroupsCount
        }
    }
}
