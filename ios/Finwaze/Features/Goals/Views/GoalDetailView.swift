import SwiftUI

/// A goal's screen (`GOAL-20…26`), pushed from its card on Goals: the goal's progress, its fields and the actions
/// that apply to it. Completing, cancelling or deleting the goal goes back to Goals, which shows the confirmation.
struct GoalDetailView: View {
    @State private var viewModel: GoalDetailViewModel
    @Environment(\.dismiss) private var dismiss
    private let app: AppViewModel
    private let onFinished: (LocalizedStringResource) -> Void

    init(app: AppViewModel, goalID: Int64, onFinished: @escaping (LocalizedStringResource) -> Void) {
        self.app = app
        self.onFinished = onFinished
        _viewModel = State(
            initialValue: GoalDetailViewModel(
                goalID: goalID,
                referenceData: app.referenceData,
                repository: app.repositories.goals,
                transfers: app.repositories.transfers,
                onChanged: { app.dataChanged() }
            )
        )
    }

    var body: some View {
        content
            .navigationTitle(viewModel.goal.map { Text(verbatim: $0.name) } ?? Text("goals.detail.title"))
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
    }

    private var content: some View {
        DetailStateView(
            state: viewModel.state,
            notFound: .init(title: "goals.notFound.title", message: "goals.notFound.message", back: "goals.notFound.back"),
            onRetry: { Task { await viewModel.load() } }
        ) { goal in
            if let form = viewModel.form {
                GoalDetailContent(
                    app: app,
                    viewModel: viewModel,
                    form: form,
                    goal: goal,
                    onFinished: { message in
                        onFinished(message)
                        dismiss()
                    }
                )
            }
        }
    }
}

/// The loaded goal — split out so `@Bindable` can observe the view models.
private struct GoalDetailContent: View {
    let app: AppViewModel
    @Bindable var viewModel: GoalDetailViewModel
    @Bindable var form: GoalFormViewModel
    let goal: SavingsGoal
    let onFinished: (LocalizedStringResource) -> Void
    @State private var closing: GoalClosingViewModel?
    @State private var isConfirmingCancel = false
    @State private var isConfirmingDelete = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GoalCardSummary(goal: goal)
                    .padding(18)
                    .background { CardBackground() }

                if form.isReadOnly {
                    // Why nothing can be changed (`GOAL-04`, `GOAL-22`).
                    Label("goals.detail.readOnly", systemImage: "lock")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                GoalFormFields(viewModel: form)

                if viewModel.hasActions {
                    actions
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            if !form.isReadOnly {
                FormConfirmItem(
                    title: "goals.form.save",
                    isSubmitting: form.isSubmitting,
                    isEnabled: form.hasChanges && !viewModel.isBusy,
                    placement: .primaryAction,
                    action: save
                )
            }
        }
        .background(Color(.systemGroupedBackground))
        .overlay(alignment: .top) {
            if viewModel.showsUpdatedBanner {
                SuccessBanner(message: "goals.updated") { viewModel.showsUpdatedBanner = false }
            }
        }
        .failureAlert($form.failure, title: "goals.updateFailed")
        .failureAlert($viewModel.cancellationFailure, title: "goals.cancelFailed")
        .failureAlert($viewModel.deletionFailure, title: "goals.deleteFailed")
        .sheet(item: $closing) { closing in
            GoalClosingSheet(app: app, viewModel: closing) {
                onFinished(closing.kind == .complete ? "goals.completed" : "goals.cancelled")
            }
        }
        // Irreversible, so confirmed first (`GEN-22`, `GOAL-24`).
        .confirmationDialog("goals.cancel.confirmTitle", isPresented: $isConfirmingCancel, titleVisibility: .visible) {
            Button("goals.cancel.confirm", role: .destructive) {
                Task {
                    if await viewModel.cancelWithoutTransfer() {
                        onFinished("goals.cancelled")
                    }
                }
            }
            Button("goals.keep", role: .cancel) {}
        } message: {
            Text("goals.cancel.confirmMessage")
        }
        .confirmationDialog("goals.delete.confirmTitle", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("goals.delete", role: .destructive) {
                Task {
                    if await viewModel.delete() {
                        onFinished("goals.deleted")
                    }
                }
            }
            Button("goals.keep", role: .cancel) {}
        } message: {
            Text("goals.delete.confirmMessage \(goal.name)")
        }
    }

    /// Only the actions that apply to the goal (`GOAL-23…25`).
    private var actions: some View {
        VStack(spacing: 12) {
            if goal.canMarkDone {
                Button {
                    closing = viewModel.closing(.complete)
                } label: {
                    Label("goals.markDone", systemImage: "checkmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .tint(.green)
            }
            if goal.canCancel {
                Button(role: .destructive) {
                    if viewModel.cancellationReturnsMoney {
                        closing = viewModel.closing(.cancel)
                    } else {
                        isConfirmingCancel = true
                    }
                } label: {
                    Label("goals.markCancelled", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
            }
            if goal.canDelete {
                FormDestructiveButton(title: "goals.delete") {
                    isConfirmingDelete = true
                }
            }
        }
        .disabled(viewModel.isBusy)
    }

    private func save() {
        Task { await form.submit() }
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(app: .preview, goalID: 101) { _ in }
    }
    .environment(AppViewModel.preview)
}
