import Foundation

nonisolated enum TransactionMapper {
    enum MappingError: Error, Equatable {
        case invalidDate(String)
        case invalidOffset(String)
    }

    static func toTransaction(_ dto: TransactionDto) throws -> Transaction {
        guard let transactedAt = parseTimestamp(dto.transactedAt) else {
            throw MappingError.invalidDate(dto.transactedAt)
        }
        // A wrong offset would silently move the transaction to another day or month (`GEN-12`).
        guard let localOffset = LocalOffset(interval: dto.localOffset) else {
            throw MappingError.invalidOffset(dto.localOffset)
        }
        return Transaction(
            id: dto.id,
            type: dto.type,
            transactedAt: transactedAt,
            localOffset: localOffset,
            transactionAmount: dto.transactionAmount,
            transactionCurrencyCode: dto.transactionCurrencyCode,
            chargedAmount: dto.chargedAmount,
            chargedCurrencyCode: dto.chargedCurrencyCode,
            accountID: dto.accountID,
            accountName: dto.accountName,
            group: Transaction.Label(id: dto.groupID, name: dto.groupName, color: dto.groupColor),
            category: Transaction.Label(id: dto.categoryID, name: dto.categoryName, color: dto.categoryColor),
            comment: dto.comment.flatMap { $0.isEmpty ? nil : $0 },
            transferID: dto.transferID
        )
    }

    static func toDto(_ transaction: NewTransaction) -> NewTransactionDto {
        NewTransactionDto(
            type: transaction.type,
            // With the `Z` designator: without it Postgres would read the time in the session's time zone.
            transactedAt: Date.ISO8601FormatStyle(includingFractionalSeconds: true, timeZone: .gmt)
                .format(transaction.transactedAt),
            localOffset: transaction.localOffset.intervalString,
            accountID: transaction.accountID,
            categoryID: transaction.categoryID,
            transactionAmount: transaction.transactionAmount,
            transactionCurrencyID: transaction.transactionCurrencyID,
            chargedAmount: transaction.chargedAmount,
            comment: transaction.comment
        )
    }

    /// The details `select` (`TX-06`): the same shape as the list row, reached through foreign keys.
    static func toTransaction(_ dto: TransactionDetailsDto) throws -> Transaction {
        guard let transactedAt = parseTimestamp(dto.transactedAt) else {
            throw MappingError.invalidDate(dto.transactedAt)
        }
        guard let localOffset = LocalOffset(interval: dto.localOffset) else {
            throw MappingError.invalidOffset(dto.localOffset)
        }
        return Transaction(
            id: dto.id,
            type: dto.type,
            transactedAt: transactedAt,
            localOffset: localOffset,
            transactionAmount: dto.transactionAmount,
            transactionCurrencyCode: dto.transactionCurrency.code,
            chargedAmount: dto.chargedAmount,
            chargedCurrencyCode: dto.chargedCurrency.code,
            accountID: dto.account.id,
            accountName: dto.account.name,
            group: Transaction.Label(
                id: dto.category.group.id,
                name: dto.category.group.name,
                color: dto.category.group.color
            ),
            category: Transaction.Label(id: dto.category.id, name: dto.category.name, color: dto.category.color),
            comment: dto.comment.flatMap { $0.isEmpty ? nil : $0 },
            transferID: dto.transferID
        )
    }

    static func toDto(_ update: TransactionUpdate) -> TransactionUpdateDto {
        TransactionUpdateDto(
            transactedAt: Date.ISO8601FormatStyle(includingFractionalSeconds: true, timeZone: .gmt)
                .format(update.transactedAt),
            localOffset: update.localOffset.intervalString,
            accountID: update.accountID,
            categoryID: update.categoryID,
            transactionAmount: update.transactionAmount,
            transactionCurrencyID: update.transactionCurrencyID,
            chargedAmount: update.chargedAmount,
            comment: update.comment
        )
    }

    /// `TIMESTAMPTZ` as PostgREST returns it: `2026-09-27T10:15:00+00:00`, with or without fractional seconds.
    static func parseTimestamp(_ text: String) -> Date? {
        let withFraction = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
        let withoutFraction = Date.ISO8601FormatStyle()
        return (try? withFraction.parse(text)) ?? (try? withoutFraction.parse(text))
    }
}
