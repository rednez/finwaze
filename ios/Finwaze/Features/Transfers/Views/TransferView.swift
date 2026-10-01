import SwiftUI

/// "Transfer money" (`TRF-01…05`), opened from the Wallet (`ACC-01`). Success closes the sheet; the Wallet and the
/// transactions list then show the new balances and the two transfer rows (`TRF-05`, `GEN-26`).
struct TransferView: View {
    @State private var viewModel: TransferFormViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focus: Field?

    private enum Field {
        case sentAmount, receivedAmount
    }

    init(app: AppViewModel) {
        _viewModel = State(
            initialValue: TransferFormViewModel(
                referenceData: app.referenceData,
                repository: app.repositories.transfers,
                onSaved: { app.dataChanged() }
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    FormSection {
                        fromAccountRow
                        sentAmountRow
                    }
                    FormSection(footer: viewModel.needsAnotherAccount ? Text("transferForm.needsAnotherAccount") : nil) {
                        toAccountRow
                        if viewModel.showsReceivedAmount {
                            receivedAmountRow
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    FormSection {
                        dateRow
                    }
                }
                .disabled(viewModel.isSubmitting)
                .animation(.default, value: viewModel.showsReceivedAmount)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("transferForm.title")
            .navigationSubtitle("transferForm.subtitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // "Back" without saving (`NAV-05`).
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel", role: .cancel) { dismiss() }
                        .disabled(viewModel.isSubmitting)
                }
                FormConfirmItem(title: "transferForm.submit", isSubmitting: viewModel.isSubmitting, action: submit)
            }
            .failureAlert($viewModel.failure, title: "transferForm.creationFailed")
        }
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }

    /// The amount leaving the source account, in its currency.
    private var sentAmountRow: some View {
        FormRow(
            label: "transferForm.sentAmount",
            systemImage: "banknote.fill",
            tint: .green,
            error: viewModel.sentAmountIssue?.message
        ) {
            FormAmountInput(title: "transferForm.sentAmount", text: $viewModel.sentAmountText, currencyCode: viewModel.fromAccount?.currencyCode)
            .focused($focus, equals: .sentAmount)
        }
    }

    private var fromAccountRow: some View {
        FormRow(
            label: "transferForm.fromAccount",
            systemImage: "arrow.up.right",
            tint: .orange,
            error: viewModel.fromAccountIssue?.message
        ) {
            AccountMenu(title: "transferForm.fromAccount", accounts: viewModel.accounts, selection: $viewModel.fromAccount)
        }
    }

    /// Empty and inactive until a source is chosen (`TRF-02`); the section's note explains why when there is no other
    /// account.
    private var toAccountRow: some View {
        FormRow(
            label: "transferForm.toAccount",
            systemImage: "arrow.down.left",
            tint: .green,
            error: viewModel.toAccountIssue?.message
        ) {
            AccountMenu(title: "transferForm.toAccount", accounts: viewModel.toAccounts, selection: $viewModel.toAccount)
                .disabled(viewModel.toAccounts.isEmpty)
        }
    }

    /// Only when the currencies differ, with the rate under it (`TRF-03`, `GEN-10`).
    private var receivedAmountRow: some View {
        FormRow(
            label: "transferForm.receivedAmount",
            systemImage: "arrow.left.arrow.right",
            tint: .indigo,
            note: viewModel.exchangeRateHint.map { Text(verbatim: $0) },
            error: viewModel.receivedAmountIssue?.message
        ) {
            FormAmountInput(title: "transferForm.receivedAmount", text: $viewModel.receivedAmountText, currencyCode: viewModel.toAccount?.currencyCode)
            .focused($focus, equals: .receivedAmount)
        }
    }

    /// Never in the future (`GEN-13`).
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
        focus = nil
        Task {
            if await viewModel.submit() {
                Haptics.success()
                dismiss()
            }
        }
    }
}

/// An account picker showing "Name · Currency" (`TRF-04`).
private struct AccountMenu: View {
    let title: LocalizedStringKey
    let accounts: [Account]
    @Binding var selection: Account?

    var body: some View {
        FormMenuValue(
            value: selection.map { Text(verbatim: "\($0.name) · \($0.currencyCode)") },
            placeholder: "transactionForm.accountPlaceholder"
        ) {
            Picker(title, selection: $selection) {
                ForEach(accounts) { account in
                    Text(verbatim: "\(account.name) · \(account.currencyCode)").tag(Account?.some(account))
                }
            }
        }
        .accessibilityLabel(Text(title))
        .accessibilityValue(selection.map { "\($0.name), \($0.currencyCode)" } ?? "")
    }
}

#Preview {
    TransferView(app: .preview)
}
