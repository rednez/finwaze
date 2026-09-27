import Foundation

nonisolated enum WalletMapper {
    static func toAccount(_ dto: WalletAccountDto) -> WalletAccount {
        WalletAccount(id: dto.id, name: dto.name, currencyCode: dto.currencyCode, balance: dto.balance)
    }

    /// Accounts in the order the Wallet shows them: by name, the way Finder sorts ("Card 2" before "Card 10").
    static func sortedByName(_ accounts: [WalletAccount]) -> [WalletAccount] {
        accounts.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    static func toDetails(_ dto: AccountDetailsDto) -> AccountDetails {
        AccountDetails(
            id: dto.id,
            name: dto.name,
            currencyID: dto.currencyID,
            currencyCode: dto.currencyCode,
            balance: dto.balance,
            canDelete: dto.canDelete
        )
    }

    static func toDto(_ update: AccountUpdate) -> AccountUpdateDto {
        AccountUpdateDto(name: update.name, currencyID: update.currencyID)
    }

    static func toDto(_ adjustment: BalanceAdjustment) -> BalanceAdjustmentDto {
        BalanceAdjustmentDto(
            accountID: adjustment.accountID,
            targetBalance: adjustment.targetBalance,
            localOffset: adjustment.localOffset.intervalString,
            // With the `Z` designator: without it Postgres would read the time in the session's time zone.
            balanceDate: Date.ISO8601FormatStyle(includingFractionalSeconds: true, timeZone: .gmt)
                .format(adjustment.balanceDate)
        )
    }
}
