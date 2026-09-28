import Foundation

/// What Analytics shows (`ANL-01`): a month in one currency, for some of its accounts or all of them.
nonisolated struct AnalyticsQuery: Hashable, Sendable {
    let month: YearMonth
    /// Figures count the amounts charged to accounts in this currency (`ANL-06`).
    let currencyCode: String
    /// Empty for every account in the currency, goal accounts included.
    let accountIDs: Set<Int64>
}

/// What "Budgets vs Expenses" shows (`ANL-04`): a year in one currency; months and accounts do not apply.
nonisolated struct AnalyticsYearKey: Hashable, Sendable {
    let year: Int
    let currencyCode: String
}
