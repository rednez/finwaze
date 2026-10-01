import SwiftUI

/// "Deposit" into a goal or "Withdraw" from it (`GOAL-13`, `GOAL-14`). Success closes the sheet and reports back with
/// the confirmation to show on Goals.
struct GoalTransferView: View {
    @State private var viewModel: GoalTransferViewModel
    @State private var isCreatingAccount = false
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isAmountFocused: Bool
    private let app: AppViewModel
    private let onDone: (LocalizedStringResource) -> Void

    init(
        app: AppViewModel,
        goal: SavingsGoal,
        direction: GoalTransferViewModel.Direction,
        onDone: @escaping (LocalizedStringResource) -> Void
    ) {
        self.app = app
        self.onDone = onDone
        _viewModel = State(
            initialValue: GoalTransferViewModel(
                goal: goal,
                direction: direction,
                referenceData: app.referenceData,
                repository: app.repositories.transfers,
                onSaved: { app.dataChanged() }
            )
        )
    }

    private var isDeposit: Bool {
        viewModel.direction == .deposit
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    GoalAccountField(
                        label: isDeposit ? "goals.transfer.fromAccount" : "goals.transfer.toAccount",
                        accounts: viewModel.accounts,
                        selection: viewModel.account,
                        currencyCode: viewModel.goal.currencyCode,
                        error: viewModel.accountIssue?.message,
                        onSelect: { viewModel.selectedAccount = $0 },
                        onCreateAccount: { isCreatingAccount = true }
                    )
                    FormSection {
                        amountRow
                        dateRow
                    }
                }
                .disabled(viewModel.isSubmitting)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isDeposit ? "goals.transfer.depositTitle" : "goals.transfer.withdrawTitle")
            .navigationSubtitle(Text(verbatim: viewModel.goal.name))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel", role: .cancel) { dismiss() }
                        .disabled(viewModel.isSubmitting)
                }
                FormConfirmItem(
                    title: isDeposit ? "goals.deposit" : "goals.withdraw",
                    isSubmitting: viewModel.isSubmitting,
                    isEnabled: !viewModel.needsAccount,
                    action: submit
                )
            }
            .failureAlert(
                $viewModel.failure,
                title: isDeposit ? "goals.transfer.depositFailed" : "goals.transfer.withdrawFailed"
            )
            .sheet(isPresented: $isCreatingAccount) {
                NewAccountView(app: app)
            }
        }
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }

    /// Up to what is saved when withdrawing (`GOAL-14`).
    private var amountRow: some View {
        FormRow(
            label: "goals.transfer.amount",
            systemImage: "banknote.fill",
            tint: .green,
            note: isDeposit ? nil : Text("goals.transfer.saved \(savedAmount)"),
            error: viewModel.amountIssue?.message
        ) {
            FormAmountInput(title: "goals.transfer.amount", text: $viewModel.amountText, currencyCode: viewModel.goal.currencyCode)
            .focused($isAmountFocused)
        }
    }

    private var savedAmount: String {
        viewModel.goal.accumulatedAmount.formattedAmount(currencyCode: viewModel.goal.currencyCode)
    }

    /// "Now" unless changed; never in the future (`GEN-13`).
    private var dateRow: some View {
        FormRow(label: "transactionForm.date", systemImage: "calendar", tint: .red, error: viewModel.dateIssue?.message) {
            DatePicker(
                "transactionForm.date",
                selection: $viewModel.transactedAt,
                in: ...viewModel.latestDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
        }
    }

    private func submit() {
        isAmountFocused = false
        Task {
            // The banner on Goals plays the success haptic.
            guard await viewModel.submit() else { return }
            if isDeposit {
                onDone("goals.transfer.deposited \(viewModel.goal.name)")
            } else {
                onDone("goals.transfer.withdrawn")
            }
            dismiss()
        }
    }
}

#Preview {
    GoalTransferView(app: .preview, goal: DemoData.savingsGoals()[0], direction: .deposit) { _ in }
}
