import Foundation

/// What a Budget screen shows: a month in one currency, either every group or one group's categories.
nonisolated struct BudgetQuery: Hashable, Sendable {
    let month: YearMonth
    let currencyCode: String
    /// `nil` for the whole month by group (`BUD-12`), a group's id for its categories (`BUD-17`).
    let groupID: Int64?
}

nonisolated extension YearMonth {
    /// The month's first day as a `DATE` parameter, `2026-09-01`. No time zone is involved: it is the user's local
    /// calendar month, which the server compares with `transacted_at + local_offset` (`GEN-12`).
    var firstDayParameter: String {
        String(format: "%04d-%02d-01", year, month)
    }
}
