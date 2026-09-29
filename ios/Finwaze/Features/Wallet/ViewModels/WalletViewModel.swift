import Foundation
import Observation

/// The Wallet's account cards (`ACC-02`) with loading, empty and error states (`GEN-23…25`).
@Observable
final class WalletViewModel {
    /// Keyed by the data version only: the accounts have no filters.
    private let accounts: CardLoader<Bool, [WalletAccount]>

    init(repository: any WalletRepository) {
        accounts = CardLoader(key: { true }) { _ in try await repository.accounts() }
    }

    var state: CardState<[WalletAccount]> {
        accounts.state
    }

    /// Loads the accounts when the data changed, not on every return to the tab (see `CardLoader`).
    func load(dataVersion: Int) async {
        await accounts.load(dataVersion: dataVersion)
    }

    /// Pull to refresh or "Try again". A reload keeps the cards on screen until the new ones arrive (`GEN-26`).
    func refresh() async {
        await accounts.refresh()
    }
}
