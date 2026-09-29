import Foundation

/// What a Budget screen shows: a month in one currency, either every group or one group's categories.
nonisolated struct BudgetQuery: Hashable, Sendable {
    let month: YearMonth
    let currencyCode: String
    /// `nil` for the whole month by group (`BUD-12`), a group's id for its categories (`BUD-17`).
    let groupID: Int64?
}
