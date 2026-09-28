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

    /// A month of the overview; a missing amount counts as nothing saved (`GOAL-16`).
    static func toMonthlySavings(_ dto: MonthlySavingsDto) throws -> MonthlySavings {
        let parts = dto.month.split(separator: "-")
        guard parts.count == 3, let year = Int(parts[0]), let month = Int(parts[1]), (1...12).contains(month) else {
            throw MappingError.invalidDate(dto.month)
        }
        return MonthlySavings(
            month: YearMonth(year: year, month: month),
            currentYear: dto.currentYearAmount ?? 0,
            previousYear: dto.previousYearAmount ?? 0
        )
    }

    static func toDto(_ goal: NewSavingsGoal, timeZone: TimeZone = .current) -> NewSavingsGoalDto {
        NewSavingsGoalDto(
            name: goal.name,
            currencyID: goal.currencyID,
            targetAmount: goal.targetAmount,
            targetDate: goal.targetDate.isoDateString(in: timeZone)
        )
    }

    static func toDto(id: Int64, _ update: SavingsGoalUpdate, timeZone: TimeZone = .current) -> SavingsGoalUpdateDto {
        SavingsGoalUpdateDto(
            accountID: id,
            name: update.name,
            targetAmount: update.targetAmount,
            targetDate: update.targetDate.isoDateString(in: timeZone)
        )
    }

    /// A `DATE` as a calendar day: midnight in `timeZone`, so it formats as the same day on this device.
    static func parseDate(_ text: String, timeZone: TimeZone = .current) -> Date? {
        try? Date.ISO8601FormatStyle(timeZone: timeZone).year().month().day().parse(text)
    }
}
