import SwiftUI

/// Where "Add budget", "Edit budget" and "Create budget" lead until the plan editor of stage 10 (`BUD-20…26`).
struct BudgetPlanPlaceholder: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("budget.plan.title", systemImage: "chart.pie")
            } description: {
                Text("section.comingSoon")
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.done", role: .confirm) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
