import Foundation

/// A sector of the budget ring (`DASH-05`).
nonisolated struct BudgetSlice: Identifiable, Equatable, Sendable {
    /// Position in the ring, largest first; picks the colour.
    let id: Int
    /// `nil` for "Other categories".
    let name: String?
    let amount: Decimal

    var isOther: Bool { name == nil }
}

/// The budget ring's sectors and total (`DASH-05`).
nonisolated struct BudgetSummary: Equatable, Sendable {
    /// With more categories than this, the smallest are joined into "Other categories", like the web.
    static let maxSlices = 7

    let slices: [BudgetSlice]
    let total: Decimal

    /// Largest first; beyond `maxSlices` categories, the six largest and "Other categories" with the rest.
    init(_ budgets: [CategoryBudget]) {
        let sorted = budgets.sorted { ($0.amount, $1.name) > ($1.amount, $0.name) }
        total = sorted.reduce(0) { $0 + $1.amount }

        let shown = sorted.count <= Self.maxSlices ? sorted : Array(sorted.prefix(Self.maxSlices - 1))
        var slices = shown.enumerated().map { index, budget in
            BudgetSlice(id: index, name: budget.name, amount: budget.amount)
        }
        if shown.count < sorted.count {
            let rest = sorted.dropFirst(shown.count).reduce(0) { $0 + $1.amount }
            slices.append(BudgetSlice(id: slices.count, name: nil, amount: rest))
        }
        self.slices = slices
    }
}
