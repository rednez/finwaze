import Foundation

/// A group's or a category's budget for a month in one currency (`BUD-01…05`, `BUD-12`, `BUD-17`). Amounts are
/// positive; "spent" counts expenses in the budget's purchase currency (`BUD-02`).
nonisolated struct BudgetItem: Identifiable, Equatable, Sendable {
    let id: Int64
    let name: String
    let planned: Decimal
    let spent: Decimal
    /// How many categories have a plan or spending this month; only for a group.
    let categoriesCount: Int?
    /// Spending without a plan (`BUD-05`).
    let isUnplanned: Bool

    /// May be negative (`BUD-03`).
    var remaining: Decimal {
        planned - spent
    }

    var status: BudgetStatus {
        BudgetStatus(planned: planned, spent: spent)
    }
}
