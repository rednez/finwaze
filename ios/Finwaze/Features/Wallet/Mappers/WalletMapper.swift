import Foundation

nonisolated enum WalletMapper {
    enum MappingError: Error, Equatable {
        case invalidDay(String)
    }

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

    /// A day of the Wallet's chart. The day is a calendar date, read in the device's time zone so it stays the same
    /// day; expenses become positive, like the web (`ACC-03`).
    static func toDailyCashFlow(_ dto: DailyCashFlowDto, timeZone: TimeZone = .current) throws -> DailyCashFlow {
        guard let day = SavingsGoalsMapper.parseDate(dto.day, timeZone: timeZone) else {
            throw MappingError.invalidDay(dto.day)
        }
        return DailyCashFlow(day: day, income: dto.totalIncome ?? 0, expense: abs(dto.totalExpense ?? 0))
    }

    /// `null` counts as 0; expenses become positive (`ACC-05`).
    static func toGroupAmounts(_ dto: GroupAmountsDto) -> GroupAmounts {
        GroupAmounts(
            id: dto.groupID,
            name: dto.groupName,
            income: dto.totalIncome ?? 0,
            expense: abs(dto.totalExpense ?? 0)
        )
    }
}
