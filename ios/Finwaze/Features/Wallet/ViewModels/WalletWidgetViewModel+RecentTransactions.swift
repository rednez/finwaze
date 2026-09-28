import Foundation

/// How many transactions "Recent transactions" shows (`ACC-04`).
nonisolated enum WalletRecentTransactions {
    static let limit = 3
}

extension WalletWidgetViewModel<[Transaction]> {
    /// "Recent transactions" (`ACC-04`): the newest in a purchase currency. It has no month; only the currency
    /// changes.
    static func recentTransactions(
        repository: any WalletRepository,
        referenceData: ReferenceDataStore,
        preferences: DevicePreferences
    ) -> WalletWidgetViewModel<[Transaction]> {
        WalletWidgetViewModel(referenceData: referenceData, preferences: preferences) { key in
            try await repository.recentTransactions(currencyCode: key.currencyCode, limit: WalletRecentTransactions.limit)
        }
    }
}
