import Foundation

nonisolated enum SavingsGoalsMapper {
    enum MappingError: Error, Equatable {
        case invalidDate(String)
    }

    static func toGoal(_ dto: SavingsGoalDto, timeZone: TimeZone = .current) throws -> SavingsGoal {
        guard let targetDate = Date(isoDate: dto.targetDate, timeZone: timeZone) else {
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
        guard let month = YearMonth(isoDate: dto.month) else {
            throw MappingError.invalidDate(dto.month)
        }
        return MonthlySavings(
            month: month,
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
}
