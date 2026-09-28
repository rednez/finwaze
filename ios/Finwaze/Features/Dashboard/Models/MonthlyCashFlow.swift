import Foundation

/// A month of the "Monthly cash flow" chart: incomes and expenses charged to accounts in one currency (`DASH-04`).
nonisolated struct MonthlyCashFlow: Identifiable, Equatable, Sendable {
    /// The first day of the month, at midnight in the device's calendar, so the chart puts it in the right month.
    let month: Date
    let income: Decimal
    /// As a positive amount, so both bars grow up.
    let expense: Decimal

    var id: Date { month }
}
