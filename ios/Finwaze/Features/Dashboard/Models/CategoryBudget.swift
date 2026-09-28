import Foundation

/// This month's planned budget of one category in one currency (`DASH-05`).
nonisolated struct CategoryBudget: Equatable, Sendable {
    let name: String
    let amount: Decimal
}

nonisolated extension SliceSummary {
    /// The budget ring's sectors: a category's planned amount each (`DASH-05`).
    init(budgets: [CategoryBudget]) {
        self.init(budgets.map { NamedAmount(name: $0.name, amount: $0.amount) })
    }
}
