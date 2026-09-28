import Foundation

/// A day of the "Daily cash flow" chart: incomes and expenses in one purchase currency (`ACC-03`).
nonisolated struct DailyCashFlow: Identifiable, Equatable, Sendable {
    /// Midnight of the day in the device's calendar, so the chart puts it on the right day.
    let day: Date
    let income: Decimal
    /// As a positive amount, so both lines grow up.
    let expense: Decimal

    var id: Date { day }
}
