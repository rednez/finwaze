import Foundation

/// A day of "Monthly overview" (`ANL-03`): the day's incomes and expenses and the balance at its end.
nonisolated struct DailyOverviewPoint: Identifiable, Equatable, Sendable {
    /// Midnight of the day in the device's calendar.
    let day: Date
    /// 1…31: the chart lays two months over each other by it.
    let dayOfMonth: Int
    let income: Decimal
    /// As a positive amount.
    let expense: Decimal
    /// At the end of the day, counting everything before the month too.
    let balance: Decimal

    var id: Int { dayOfMonth }
}

/// "Monthly overview" (`ANL-03`): the month and the one before, loaded together, since one line alone compares
/// nothing.
nonisolated struct MonthlyOverview: Equatable, Sendable {
    let current: [DailyOverviewPoint]
    let previous: [DailyOverviewPoint]
}
