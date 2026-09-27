import Foundation

/// Demo-mode Wallet: balances from `DemoData`, never from the network (`AUTH-10`).
nonisolated struct DemoWalletRepository: WalletRepository {
    func accounts() async throws -> [WalletAccount] {
        WalletMapper.sortedByName(DemoData.walletAccounts)
    }
}
