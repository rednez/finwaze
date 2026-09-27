import Foundation

nonisolated enum WalletMapper {
    static func toAccount(_ dto: WalletAccountDto) -> WalletAccount {
        WalletAccount(id: dto.id, name: dto.name, currencyCode: dto.currencyCode, balance: dto.balance)
    }

    /// Accounts in the order the Wallet shows them: by name, the way Finder sorts ("Card 2" before "Card 10").
    static func sortedByName(_ accounts: [WalletAccount]) -> [WalletAccount] {
        accounts.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
