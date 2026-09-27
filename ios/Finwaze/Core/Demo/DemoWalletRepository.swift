import Foundation

/// Demo-mode Wallet: balances from `DemoData`, never from the network (`AUTH-10`).
nonisolated struct DemoWalletRepository: WalletRepository {
    func accounts() async throws -> [WalletAccount] {
        WalletMapper.sortedByName(DemoData.walletAccounts)
    }

    func accountDetails(id: Int64) async throws -> AccountDetails? {
        guard
            let account = DemoData.walletAccounts.first(where: { $0.id == id }),
            let currency = DemoData.currencies.first(where: { $0.code == account.currencyCode })
        else { return nil }
        return AccountDetails(
            id: account.id,
            name: account.name,
            currencyID: currency.id,
            currencyCode: currency.code,
            balance: account.balance,
            canDelete: !DemoData.accountIDsWithTransactions.contains(account.id)
        )
    }

    /// A no-op, like on the web: nothing is stored, so the demo never changes.
    func updateAccount(id: Int64, _ update: AccountUpdate) async throws -> Bool {
        true
    }

    /// A no-op, like `updateAccount`.
    func adjustBalance(_ adjustment: BalanceAdjustment) async throws {}

    /// A no-op, like `updateAccount`: the "deleted" account stays in place.
    func deleteAccount(id: Int64) async throws {}
}
