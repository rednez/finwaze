import Foundation

/// How a budget is doing (`BUD-04`): "On track" while at least 20 % of the plan is left, "Attention" from 20 % down
/// to nothing left, "Over budget" once spending passes the plan. Spending without a plan is over budget too (`BUD-05`).
nonisolated enum BudgetStatus: CaseIterable, Hashable, Sendable {
    case onTrack, attention, overBudget

    /// Worked out without dividing, so there is no rounding at the 20 % edge (`GEN-09`).
    init(planned: Decimal, spent: Decimal) {
        let remaining = planned - spent
        if planned <= 0 || remaining < 0 {
            self = .overBudget
        } else if remaining * 5 >= planned {
            self = .onTrack
        } else {
            self = .attention
        }
    }
}
