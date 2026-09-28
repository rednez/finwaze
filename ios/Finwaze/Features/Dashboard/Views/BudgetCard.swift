import SwiftUI

/// "Budget": this month's plan in the primary currency by category, as a ring with the total in the middle
/// (`DASH-05`).
struct BudgetCard: View {
    let state: CardState<SliceSummary>
    let currencyCode: String
    let onRetry: () -> Void
    let onOpenBudget: () -> Void

    var body: some View {
        ContentCard(title: "dashboard.budget.title") {
            CardStateView(state: state, placeholder: .placeholder, onRetry: onRetry) { summary in
                if summary.slices.isEmpty {
                    CardEmptyState(
                        title: "dashboard.budget.empty.title",
                        message: "dashboard.budget.empty.message",
                        actionTitle: "dashboard.budget.open",
                        action: onOpenBudget
                    )
                } else {
                    DonutChart(summary: summary, currencyCode: currencyCode, caption: "dashboard.budget.total")
                }
            }
        }
    }
}

private extension SliceSummary {
    /// A skeleton ring while the budget loads (`GEN-23`).
    static let placeholder = SliceSummary(budgets: [
        CategoryBudget(name: "Rent", amount: 1200),
        CategoryBudget(name: "Groceries", amount: 400),
        CategoryBudget(name: "Transport", amount: 150),
    ])
}
