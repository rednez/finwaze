import SwiftUI

/// "New goal" (`GOAL-20`, `GOAL-21`): creating it creates its account too. Success closes the sheet; Goals then
/// shows the goal as not started (`GEN-26`).
struct NewGoalView: View {
    @State private var viewModel: GoalFormViewModel
    @Environment(\.dismiss) private var dismiss

    init(app: AppViewModel) {
        _viewModel = State(
            initialValue: GoalFormViewModel(
                mode: .create,
                referenceData: app.referenceData,
                repository: app.repositories.goals,
                defaultCurrencyCode: app.preferences.primaryCurrencyCode,
                onSaved: { app.dataChanged() }
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                GoalFormFields(viewModel: viewModel)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("goals.new.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel", role: .cancel) { dismiss() }
                        .disabled(viewModel.isSubmitting)
                }
                FormConfirmItem(title: "goals.form.create", isSubmitting: viewModel.isSubmitting, action: submit)
            }
            .failureAlert($viewModel.failure, title: "goals.new.failed")
        }
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }

    private func submit() {
        Task {
            if await viewModel.submit() {
                Haptics.success()
                dismiss()
            }
        }
    }
}

#Preview {
    NewGoalView(app: .preview)
}
