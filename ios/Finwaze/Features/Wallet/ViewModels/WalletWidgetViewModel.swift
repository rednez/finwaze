import Foundation
import Observation

/// One Wallet widget's data by its own filters (`ACC-03…06`): loaded, reloaded and retried on its own, so another
/// widget's filters or failure never touch it (`GEN-25`).
@Observable
final class WalletWidgetViewModel<Value: Equatable & Sendable> {
    /// What the widget shows data for.
    struct Key: Equatable {
        let month: YearMonth
        let currencyCode: String
    }

    private(set) var state: CardState<Value> = .loading
    let filter: WalletWidgetFilter

    private let referenceData: ReferenceDataStore
    private let preferences: DevicePreferences
    private let fetch: (Key) async throws -> Value
    /// What `state` holds data for, and the data version it was loaded at.
    @ObservationIgnored private var shownKey: Key?
    @ObservationIgnored private var shownDataVersion: Int?
    /// The latest data version the view asked for.
    @ObservationIgnored private var dataVersion = 0

    init(
        referenceData: ReferenceDataStore,
        preferences: DevicePreferences,
        filter: WalletWidgetFilter = WalletWidgetFilter(),
        fetch: @escaping (Key) async throws -> Value
    ) {
        self.referenceData = referenceData
        self.preferences = preferences
        self.filter = filter
        self.fetch = fetch
    }

    /// The currencies of the user's accounts, alphabetically (`GEN-11`).
    var currencyCodes: [String] {
        referenceData.accountCurrencyCodes.sorted()
    }

    /// The currency picked here; until then the primary currency (`ACC-06`, `DASH-01`).
    var currencyCode: String? {
        filter.currencyCode(among: currencyCodes, primary: preferences.primaryCurrencyCode)
    }

    var key: Key? {
        currencyCode.map { Key(month: filter.month, currencyCode: $0) }
    }

    func selectCurrency(_ code: String) {
        filter.selectCurrency(code)
    }

    func shiftMonth(by months: Int) {
        filter.shiftMonth(by: months)
    }

    /// Brings the widget up to date. Another month or currency shows a skeleton — figures of the previous one would
    /// be wrong; a change to the data keeps the figures until the new ones arrive (`GEN-26`). Nothing loads when both
    /// are as shown, e.g. when coming back to the tab.
    func load(dataVersion: Int) async {
        self.dataVersion = dataVersion
        guard let key else {
            // Only without accounts, which the main app never is (`NAV-07`).
            state = .failed
            return
        }
        if key != shownKey {
            state = .loading
        } else if dataVersion == shownDataVersion, state != .loading {
            return
        }
        await reload(key)
    }

    /// Pull to refresh or "Try again": reloads, keeping the figures until the new ones arrive.
    func refresh() async {
        guard let key else { return }
        await reload(key)
    }

    private func reload(_ key: Key) async {
        let dataVersion = dataVersion
        if case .failed = state {
            state = .loading
        }
        let result: CardState<Value>
        do {
            result = .loaded(try await fetch(key))
        } catch {
            result = .failed
        }
        // A response for a filter no longer selected, or for a load the view gave up on, is dropped.
        guard !Task.isCancelled, self.key == key else { return }
        state = result
        shownKey = key
        shownDataVersion = dataVersion
    }
}
