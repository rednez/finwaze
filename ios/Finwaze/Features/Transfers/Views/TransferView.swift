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
                onSaved: { app.transferMade() }
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        fromAccountField
                        sentAmountField
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title)
                            .foregroundStyle(.tint)
                            .accessibilityHidden(true)
                        toAccountField
                        receivedAmountField
                        dateField
                    }
                    .disabled(viewModel.isSubmitting)
                    .animation(.default, value: viewModel.showsReceivedAmount)

                    SubmitButton(title: "transferForm.submit", isLoading: viewModel.isSubmitting, action: submit)
                }
                .padding(24)
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
            }
            .failureAlert($viewModel.failure, title: "transferForm.creationFailed")
        }
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }

    private var fromAccountField: some View {
        FormField(label: "transferForm.fromAccount", error: viewModel.fromAccountIssue?.message) {
            AccountMenu(
                title: "transferForm.fromAccount",
                accounts: viewModel.accounts,
                selection: $viewModel.fromAccount
            )
        }
    }

    private var sentAmountField: some View {
        FormField(
            label: "transferForm.sentAmount",
            error: viewModel.sentAmountIssue?.message,
            isFocused: focus == .sentAmount
        ) {
            AmountInput(
                text: $viewModel.sentAmountText,
                currencyCode: viewModel.fromAccount?.currencyCode
            )
            .focused($focus, equals: .sentAmount)
        }
    }

    /// Empty and inactive until a source is chosen (`TRF-02`); explains why when there is no other account.
    private var toAccountField: some View {
        VStack(alignment: .leading, spacing: 6) {
            FormField(label: "transferForm.toAccount", error: viewModel.toAccountIssue?.message) {
                AccountMenu(
                    title: "transferForm.toAccount",
                    accounts: viewModel.toAccounts,
                    selection: $viewModel.toAccount
                )
                .disabled(viewModel.toAccounts.isEmpty)
            }
            if viewModel.needsAnotherAccount {
                Text("transferForm.needsAnotherAccount")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)
            }
        }
    }

    /// Only when the currencies differ, with the rate below it (`TRF-03`, `GEN-10`).
    @ViewBuilder
    private var receivedAmountField: some View {
        if viewModel.showsReceivedAmount {
            VStack(alignment: .leading, spacing: 6) {
                FormField(
                    label: "transferForm.receivedAmount",
                    error: viewModel.receivedAmountIssue?.message,
                    isFocused: focus == .receivedAmount
                ) {
                    AmountInput(
                        text: $viewModel.receivedAmountText,
                        currencyCode: viewModel.toAccount?.currencyCode
                    )
                    .focused($focus, equals: .receivedAmount)
                }
                if let hint = viewModel.exchangeRateHint {
                    Text(verbatim: hint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 8)
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    /// Never in the future (`GEN-13`).
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
        focus = nil
        Task {
            if await viewModel.submit() {
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
        Menu {
            Picker(title, selection: $selection) {
                ForEach(accounts) { account in
                    Text(verbatim: "\(account.name) · \(account.currencyCode)").tag(Account?.some(account))
                }
            }
        } label: {
            PickerRowLabel(
                value: selection.map { Text(verbatim: "\($0.name) · \($0.currencyCode)") },
                placeholder: "transactionForm.accountPlaceholder"
            )
        }
        .accessibilityValue(selection.map { "\($0.name), \($0.currencyCode)" } ?? "")
    }
}

/// A decimal amount with the account's currency next to it.
private struct AmountInput: View {
    @Binding var text: String
    let currencyCode: String?

    var body: some View {
        HStack {
            TextField("transactionForm.amountPlaceholder", text: $text)
                .keyboardType(.decimalPad)
                .monospacedDigit()
            if let currencyCode {
                CurrencyBadge(code: currencyCode)
            }
        }
    }
}

#Preview {
    TransferView(app: .preview)
}
