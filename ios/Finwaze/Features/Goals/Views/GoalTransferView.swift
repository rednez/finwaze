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
                onSaved: { app.goalsChanged() }
            )
        )
    }

    private var isDeposit: Bool {
        viewModel.direction == .deposit
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        GoalAccountField(
                            label: isDeposit ? "goals.transfer.fromAccount" : "goals.transfer.toAccount",
                            accounts: viewModel.accounts,
                            selection: viewModel.account,
                            currencyCode: viewModel.goal.currencyCode,
                            error: viewModel.accountIssue?.message,
                            onSelect: { viewModel.selectedAccount = $0 },
                            onCreateAccount: { isCreatingAccount = true }
                        )
                        amountField
                        dateField
                    }
                    .disabled(viewModel.isSubmitting)

                    SubmitButton(
                        title: isDeposit ? "goals.deposit" : "goals.withdraw",
                        isLoading: viewModel.isSubmitting,
                        action: submit
                    )
                    .disabled(viewModel.needsAccount)
                }
                .padding(24)
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
    private var amountField: some View {
        VStack(alignment: .leading, spacing: 6) {
            FormField(label: "goals.transfer.amount", error: viewModel.amountIssue?.message, isFocused: isAmountFocused) {
                HStack {
                    TextField("transactionForm.amountPlaceholder", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                        .monospacedDigit()
                        .focused($isAmountFocused)
                    CurrencyBadge(code: viewModel.goal.currencyCode)
                }
            }
            if !isDeposit {
                let saved = viewModel.goal.accumulatedAmount.formattedAmount(currencyCode: viewModel.goal.currencyCode)
                Text("goals.transfer.saved \(saved)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)
            }
        }
    }

    /// "Now" unless changed; never in the future (`GEN-13`).
    private var dateField: some View {
        FormField(label: "transactionForm.date", error: viewModel.dateIssue?.message) {
            DatePicker(
                "transactionForm.date",
                selection: $viewModel.transactedAt,
                in: ...viewModel.latestDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func submit() {
        isAmountFocused = false
        Task {
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
