import Foundation

nonisolated enum AnalyticsMapper {
    enum MappingError: Error, Equatable {
        case invalidDay(String)
        case invalidMonth(String)
    }

    /// `null` and a missing row count as 0 (`ANL-02`).
    static func toSummary(_ dto: AnalyticsSummaryDto?) -> AnalyticsSummary {
        guard let dto else { return .zero }
        return AnalyticsSummary(
            monthlyIncome: dto.monthlyIncome ?? 0,
            previousMonthlyIncome: dto.previousMonthlyIncome ?? 0,
            monthlyExpense: abs(dto.monthlyExpense ?? 0),
            previousMonthlyExpense: abs(dto.previousMonthlyExpense ?? 0),
            totalBalance: dto.totalBalance ?? 0,
            previousTotalBalance: dto.previousTotalBalance ?? 0,
            incomeTransactionCount: dto.incomeTransactionCount ?? 0,
            expenseTransactionCount: dto.expenseTransactionCount ?? 0,
            incomeGroupsCount: dto.incomeGroupsCount ?? 0,
            expenseGroupsCount: dto.expenseGroupsCount ?? 0
        )
    }

    /// A day of "Monthly overview". The day is a calendar date, read in the device's time zone so it stays the same
    /// day, like `WalletMapper.toDailyCashFlow` (`ANL-03`).
    static func toDailyPoint(
        _ dto: DailyOverviewPointDto,
        calendar: Calendar = .current
    ) throws -> DailyOverviewPoint {
        guard let day = SavingsGoalsMapper.parseDate(dto.day, timeZone: calendar.timeZone) else {
            throw MappingError.invalidDay(dto.day)
        }
        return DailyOverviewPoint(
            day: day,
            dayOfMonth: calendar.component(.day, from: day),
            income: dto.dailyIncome ?? 0,
            expense: abs(dto.dailyExpense ?? 0),
            balance: dto.runningBalance ?? 0
        )
    }

    /// `null` counts as 0; both amounts positive (`ANL-05`).
    static func toGroupAmounts(_ dto: AnalyticsGroupAmountsDto) -> GroupAmounts {
        GroupAmounts(
            id: dto.groupID,
            name: dto.groupName,
            income: dto.incomeAmount ?? 0,
            expense: abs(dto.expenseAmount ?? 0)
        )
    }

    /// A month of "Budgets vs Expenses", read from the `DATE` text without any time zone (`ANL-04`).
    static func toMonthlyBudgetExpense(_ dto: MonthlyBudgetExpenseDto) throws -> MonthlyBudgetExpense {
        let parts = dto.month.prefix(10).split(separator: "-")
        guard
            parts.count == 3,
            let year = Int(parts[0]),
            let month = Int(parts[1]),
            (1...12).contains(month)
        else { throw MappingError.invalidMonth(dto.month) }
        return MonthlyBudgetExpense(
            month: YearMonth(year: year, month: month),
            budget: dto.budgetAmount ?? 0,
            expense: abs(dto.expenseAmount ?? 0)
        )
    }

    /// The year's months in order, from the server's rows.
    static func toYear(_ dtos: [MonthlyBudgetExpenseDto]) throws -> [MonthlyBudgetExpense] {
        try dtos.map(toMonthlyBudgetExpense).sorted { ($0.month.year, $0.month.month) < ($1.month.year, $1.month.month) }
    }
}
