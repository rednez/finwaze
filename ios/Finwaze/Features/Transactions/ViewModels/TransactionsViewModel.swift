import Foundation
import Observation

/// The transactions list with its filters (`TX-01…08`) and loading, empty and error states (`GEN-23…25`).
/// Lives as long as the Transactions tab, so the filters survive switching tabs (`TX-08`).
@Observable
final class TransactionsViewModel {
    enum State: Equatable {
        case loading
        case loaded([Transaction])
        /// The user has no transactions at all (`TX-07`). A filter that matches nothing is `loaded([])`.
        case empty
        case failed
    }

    private(set) var state: State = .loading
    var filters: TransactionFilters

    private let repository: any TransactionsRepository
    private let referenceData: ReferenceDataStore
    /// What the list on screen was loaded for.
    @ObservationIgnored private var loadedFilters: TransactionFilters?
    @ObservationIgnored private var loadedDataVersion: Int?

    init(
        repository: any TransactionsRepository,
        referenceData: ReferenceDataStore,
        filters: TransactionFilters = TransactionFilters()
    ) {
        self.repository = repository
        self.referenceData = referenceData
        self.filters = filters
    }

    // MARK: Filter options (TX-03)

    /// Currencies of the user's accounts (`GEN-11`).
    var currencyCodes: [String] {
        referenceData.accountCurrencyCodes
    }

    /// Accounts, only those in the selected currency when there is one.
    var accounts: [Account] {
        referenceData.accounts.filter { filters.currencyCode == nil || $0.currencyCode == filters.currencyCode }
    }

    /// Every user group; system ones never reach reference data (`GEN-05`).
    var groups: [CategoryGroup] {
        referenceData.groups
    }

    /// Categories of the selected group; none until a group is selected.
    var categories: [Category] {
        guard let groupID = filters.groupID else { return [] }
        return referenceData.categories.filter { $0.groupID == groupID }
    }

    // MARK: Loading

    /// Loads the list when the filters or the data changed, not on every return to the tab.
    func load(dataVersion: Int) async {
        guard filters != loadedFilters || dataVersion != loadedDataVersion else { return }
        let filters = filters
        await load()
        // Not when interrupted or failed: the next appearance tries again.
        guard !Task.isCancelled, state != .failed else { return }
        loadedFilters = filters
        loadedDataVersion = dataVersion
    }

    /// Loads the list for the current filters: pull to refresh or "Try again". A reload keeps the rows on screen until
    /// the new ones arrive (`GEN-26`).
    func load() async {
        if case .failed = state {
            state = .loading
        }
        let query = filters.query(categories: referenceData.categories)
        do {
            let list = try await Self.transactions(matching: query, in: repository)
            // Only an empty list needs to tell "no transactions at all" from "no matches".
            let hasAny = if list.isEmpty { try await repository.hasTransactions() } else { true }
            guard !Task.isCancelled else { return }
            state = hasAny ? .loaded(list) : .empty
        } catch {
            // A newer load (another filter) replaced this one; it sets the state.
            guard !Task.isCancelled else { return }
            state = .failed
        }
    }

    /// `nil` is a query nothing can match, answered without a request.
    private nonisolated static func transactions(
        matching query: TransactionQuery?,
        in repository: any TransactionsRepository
    ) async throws -> [Transaction] {
        guard let query else { return [] }
        return try await repository.transactions(matching: query)
    }
}
