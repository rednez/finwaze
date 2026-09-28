import Foundation

/// User-facing texts for the plan editor's amount issues (`BUD-25`, `GEN-07`).
extension PositiveAmountInput.Issue {
    var planMessage: LocalizedStringResource {
        switch self {
        case .required, .notPositive: "budget.plan.amountMustBeGreater"
        case .tooPrecise: "transactionForm.amountTooPrecise"
        }
    }
}
