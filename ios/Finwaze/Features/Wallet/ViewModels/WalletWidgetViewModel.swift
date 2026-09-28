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

    let filter: WalletWidgetFilter

    private let referenceData: ReferenceDataStore
    private let preferences: DevicePreferences
    private let loader: CardLoader<Key, Value>

    init(
        referenceData: ReferenceDataStore,
        preferences: DevicePreferences,
        filter: WalletWidgetFilter = WalletWidgetFilter(),
        fetch: @escaping (Key) async throws -> Value
    ) {
        self.referenceData = referenceData
        self.preferences = preferences
        self.filter = filter
        loader = CardLoader(
            key: {
                Self.currencyCode(filter: filter, referenceData: referenceData, preferences: preferences)
                    .map { Key(month: filter.month, currencyCode: $0) }
            },
            fetch: fetch
        )
    }

    var state: CardState<Value> {
        loader.state
    }

    /// The currencies of the user's accounts, alphabetically (`GEN-11`).
    var currencyCodes: [String] {
        Self.currencyCodes(referenceData)
    }

    /// The currency picked here; until then the primary currency (`ACC-06`, `DASH-01`).
    var currencyCode: String? {
        Self.currencyCode(filter: filter, referenceData: referenceData, preferences: preferences)
    }

    var key: Key? {
        loader.key
    }

    func selectCurrency(_ code: String) {
        filter.selectCurrency(code)
    }

    func shiftMonth(by months: Int) {
        filter.shiftMonth(by: months)
    }

    /// Brings the widget up to date; see `CardLoader.load(dataVersion:)`.
    func load(dataVersion: Int) async {
        await loader.load(dataVersion: dataVersion)
    }

    /// Pull to refresh or "Try again": reloads, keeping the figures until the new ones arrive.
    func refresh() async {
        await loader.refresh()
    }

    private static func currencyCodes(_ referenceData: ReferenceDataStore) -> [String] {
        referenceData.accountCurrencyCodes.sorted()
    }

    private static func currencyCode(
        filter: WalletWidgetFilter,
        referenceData: ReferenceDataStore,
        preferences: DevicePreferences
    ) -> String? {
        filter.currencyCode(among: currencyCodes(referenceData), primary: preferences.primaryCurrencyCode)
    }
}
