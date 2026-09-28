import Foundation

nonisolated enum DashboardMapper {
    enum MappingError: Error, Equatable {
        case invalidMonth(String)
    }

    /// The server's calendar: it groups months and picks "this month" in UTC (see `ios/docs/TECH_DEBT.md`).
    static let serverCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()

    /// `null` counts as 0; expenses become positive, like the web.
    static func toTotals(_ dto: DashboardTotalsDto?) -> DashboardTotals {
        guard let dto else { return .zero }
        return DashboardTotals(
            totalBalance: dto.totalBalance ?? 0,
            monthlyIncome: dto.monthlyIncome ?? 0,
            monthlyExpense: abs(dto.monthlyExpense ?? 0),
            previousTotalBalance: dto.previousTotalBalance ?? 0,
            previousMonthlyIncome: dto.previousMonthlyIncome ?? 0,
            previousMonthlyExpense: abs(dto.previousMonthlyExpense ?? 0)
        )
    }

    static func toBudget(_ dto: CategoryBudgetDto) -> CategoryBudget {
        CategoryBudget(name: dto.categoryName, amount: dto.totalBudget)
    }

    /// The last `months` months up to the server's current one, oldest first. The server leaves out months without
    /// transactions; they come back here as zeros, so the chart always spans the whole period (`DASH-04`).
    /// - Parameter calendar: the device's calendar the months are expressed in.
    static func toCashFlow(
        _ dtos: [MonthlyCashFlowDto],
        months: Int,
        now: Date = .now,
        calendar: Calendar = .current
    ) throws -> [MonthlyCashFlow] {
        var byMonth: [YearMonth: MonthlyCashFlowDto] = [:]
        for dto in dtos {
            // The month starts at midnight UTC: read in the device's time zone west of UTC, it would be last month.
            guard let date = TransactionMapper.parseTimestamp(dto.month) else {
                throw MappingError.invalidMonth(dto.month)
            }
            byMonth[YearMonth(date, in: serverCalendar)] = dto
        }

        return lastMonths(months, now: now).compactMap { month in
            guard let start = month.start(in: calendar) else { return nil }
            let dto = byMonth[month]
            return MonthlyCashFlow(
                month: start,
                income: dto?.totalIncome ?? 0,
                expense: abs(dto?.totalExpense ?? 0)
            )
        }
    }

    /// The server's last `count` months up to the current one (in UTC), oldest first.
    static func lastMonths(_ count: Int, now: Date = .now) -> [YearMonth] {
        let current = YearMonth(now, in: serverCalendar)
        return (0..<max(count, 0)).reversed().map { current.adding(months: -$0) }
    }
}
