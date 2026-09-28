import Foundation

/// This month's planned budget of one category in one currency (`DASH-05`).
nonisolated struct CategoryBudget: Equatable, Sendable {
    let name: String
    let amount: Decimal
}
