import Foundation

/// The planned and spent totals of a month, or of one group in it (`BUD-13`, `BUD-17`).
nonisolated struct BudgetTotals: Equatable, Sendable {
    let planned: Decimal
    let spent: Decimal

    static let zero = BudgetTotals(planned: 0, spent: 0)

    /// May be negative (`BUD-03`).
    var remaining: Decimal {
        planned - spent
    }

    /// Whether there is a plan at all: "Edit budget" rather than "Add budget" (`BUD-15`).
    var hasPlan: Bool {
        planned > 0
    }

    var status: BudgetStatus {
        BudgetStatus(planned: planned, spent: spent)
    }
}
