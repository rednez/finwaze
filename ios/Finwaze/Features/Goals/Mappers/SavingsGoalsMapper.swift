import Foundation

nonisolated enum SavingsGoalsMapper {
    enum MappingError: Error, Equatable {
        case invalidDate(String)
    }

    static func toGoal(_ dto: SavingsGoalDto, timeZone: TimeZone = .current) throws -> SavingsGoal {
        guard let targetDate = parseDate(dto.targetDate, timeZone: timeZone) else {
            throw MappingError.invalidDate(dto.targetDate)
        }
        return SavingsGoal(
            id: dto.id,
            name: dto.name,
            currencyCode: dto.currencyCode,
            targetDate: targetDate,
            status: dto.status,
            targetAmount: dto.targetAmount,
            accumulatedAmount: dto.accumulatedAmount,
            hasTransfers: dto.hasTransfers
        )
    }

    /// A `DATE` as a calendar day: midnight in `timeZone`, so it formats as the same day on this device.
    static func parseDate(_ text: String, timeZone: TimeZone = .current) -> Date? {
        try? Date.ISO8601FormatStyle(timeZone: timeZone).year().month().day().parse(text)
    }
}
