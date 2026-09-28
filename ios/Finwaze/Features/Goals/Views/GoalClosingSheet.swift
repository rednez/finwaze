import SwiftUI

/// "Goal achieved!" (`GOAL-23`) or cancelling a goal with money in it (`GOAL-24`): the amount going back and the
/// regular account it goes to. Success closes the sheet and the goal's screen.
struct GoalClosingSheet: View {
    let app: AppViewModel
    @Bindable var viewModel: GoalClosingViewModel
    let onFinished: () -> Void
    @State private var isCreatingAccount = false
    @Environment(\.dismiss) private var dismiss

    private var isCompleting: Bool {
        viewModel.kind == .complete
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Label(
                        isCompleting ? "goals.complete.message" : "goals.cancel.returnMessage",
                        systemImage: isCompleting ? "party.popper" : "exclamationmark.triangle"
                    )
                    .font(.subheadline)
                    .foregroundStyle(isCompleting ? .green : .orange)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        (isCompleting ? Color.green : Color.orange).opacity(0.12),
                        in: .rect(cornerRadius: 16)
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(isCompleting ? "goals.complete.amount" : "goals.cancel.amount")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(verbatim: viewModel.amount.formattedAmount(currencyCode: viewModel.goal.currencyCode))
                            .font(.title2.weight(.semibold))
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)

                    if viewModel.hasMovedMoney {
                        // The money is back; only marking the goal failed.
                        Label("goals.closing.moneyMoved", systemImage: "checkmark.circle")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        GoalAccountField(
                            label: "goals.closing.toAccount",
                            accounts: viewModel.accounts,
                            selection: viewModel.account,
                            currencyCode: viewModel.goal.currencyCode,
                            error: viewModel.accountIssue?.message,
                            onSelect: { viewModel.selectedAccount = $0 },
                            onCreateAccount: { isCreatingAccount = true }
                        )
                        .disabled(viewModel.isSubmitting)
                    }

                    VStack(spacing: 12) {
                        SubmitButton(
                            title: isCompleting ? "goals.complete.submit" : "goals.cancel.submit",
                            isLoading: viewModel.isSubmitting,
                            action: submit
                        )
                        .tint(isCompleting ? .green : .red)
                        .disabled(viewModel.needsAccount)

                        Button(isCompleting ? "goals.complete.keepSaving" : "goals.keep") { dismiss() }
                            .disabled(viewModel.isSubmitting)
                    }
                }
                .padding(24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isCompleting ? "goals.complete.title" : "goals.cancel.title")
            .navigationBarTitleDisplayMode(.inline)
            .failureAlert(
                $viewModel.failure,
                title: isCompleting ? "goals.completeFailed" : "goals.cancelFailed"
            )
            .sheet(isPresented: $isCreatingAccount) {
                NewAccountView(app: app)
            }
        }
        .presentationDetents([.medium, .large])
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }

    private func submit() {
        Task {
            guard await viewModel.submit() else { return }
            dismiss()
            onFinished()
        }
    }
}
