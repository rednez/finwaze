import SwiftUI

/// "Account settings" (`ACC-09…12`): pushed from an account card in the Wallet, with its own "Update" and "Delete" —
/// not a sheet, so a plain back button leaves without saving (`NAV-05`).
struct AccountSettingsView: View {
    @State private var viewModel: AccountSettingsViewModel

    init(app: AppViewModel, accountID: Int64, preview: WalletAccount? = nil) {
        _viewModel = State(
            initialValue: AccountSettingsViewModel(
                accountID: accountID,
                preview: preview,
                referenceData: app.referenceData,
                repository: app.repositories.wallet,
                onChanged: { await app.referenceDataChanged() },
                onDeleted: { await app.referenceDataChanged() }
            )
        )
    }

    var body: some View {
        content
            .navigationTitle("accountSettings.title")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
    }

    private var content: some View {
        DetailStateView(
            state: viewModel.state,
            notFound: .init(
                title: "accountSettings.notFound.title",
                message: "accountSettings.notFound.message",
                back: "accountSettings.notFound.back"
            ),
            onRetry: { Task { await viewModel.load() } }
        ) { _ in
            AccountSettingsForm(viewModel: viewModel)
        }
    }
}

/// Name, currency, balance "as of" and the actions — split out so `@Bindable` can observe the view model.
private struct AccountSettingsForm: View {
    @Bindable var viewModel: AccountSettingsViewModel
    @State private var isPickingCurrency = false
    @State private var isConfirmingDelete = false
    @FocusState private var focus: Field?
    @Environment(\.dismiss) private var dismiss

    private enum Field {
        case name, balance
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 20) {
                    FormSection(footer: viewModel.canDelete ? nil : lockedHint) {
                        nameRow
                        currencyRow
                    }
                    FormSection {
                        balanceRow
                        balanceDateRows
                    }
                }
                .disabled(viewModel.isSubmitting || viewModel.isDeleting)
                .animation(.default, value: viewModel.usesBalanceDate)

                FormDestructiveButton(
                    title: "accountSettings.delete",
                    isEnabled: viewModel.canDelete && !viewModel.isSubmitting && !viewModel.isDeleting
                ) {
                    isConfirmingDelete = true
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            FormConfirmItem(
                title: "accountSettings.update",
                isSubmitting: viewModel.isSubmitting,
                isEnabled: !viewModel.isDeleting,
                placement: .primaryAction,
                action: submit
            )
        }
        .sheet(isPresented: $isPickingCurrency) {
            CurrencyPicker(currencies: viewModel.currencies, selection: $viewModel.currency)
        }
        .failureAlert($viewModel.failure, title: "accountSettings.updateFailed")
        .failureAlert($viewModel.deletionFailure, title: "accountSettings.deletionFailed")
        // A destructive confirmation before deleting (`GEN-22`, `Q-01`).
        .confirmationDialog(
            "accountSettings.deleteConfirmTitle",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button("accountSettings.delete", role: .destructive) {
                Task {
                    // Back to the Wallet on success (`ACC-12`); a failure stays on screen with an alert.
                    if await viewModel.delete() {
                        Haptics.success()
                        dismiss()
                    }
                }
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("accountSettings.deleteConfirmMessage \(viewModel.details?.name ?? "")")
        }
    }

    /// Why the currency and "Delete" are unavailable (`ACC-10`, `ACC-11`).
    private var lockedHint: Text {
        Text("\(Image(systemName: "info.circle")) \(Text("accountSettings.lockedHint"))")
    }

    private var nameRow: some View {
        FormRow(label: "accountForm.name", systemImage: "creditcard.fill", tint: .blue, error: viewModel.nameIssue?.message) {
            TextField("accountForm.namePlaceholder", text: $viewModel.name)
                .textInputAutocapitalization(.sentences)
                .focused($focus, equals: .name)
                .accessibilityLabel(Text("accountForm.name"))
        }
    }

    /// The full directory while the account has no transactions; locked otherwise (`ACC-10`).
    private var currencyRow: some View {
        FormRow(
            label: "accountForm.currency",
            systemImage: "banknote.fill",
            tint: .green,
            error: viewModel.currencyIssue?.message
        ) {
            Button {
                focus = nil
                isPickingCurrency = true
            } label: {
                FormValueLabel(
                    value: viewModel.currency.map { Text(verbatim: $0.displayName) },
                    placeholder: "accountForm.currencyPlaceholder",
                    systemImage: viewModel.isCurrencyEditable ? "chevron.right" : "lock.fill"
                )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.isCurrencyEditable)
            .accessibilityLabel(Text("accountForm.currency"))
            .accessibilityValue(viewModel.currency?.displayName ?? "")
        }
    }

    /// May be negative, so the keyboard has a minus (`ACC-09`).
    private var balanceRow: some View {
        FormRow(
            label: "accountSettings.balance",
            systemImage: "banknote.fill",
            tint: .green,
            error: viewModel.balanceIssue?.message
        ) {
            FormAmountInput(
                title: "accountSettings.balance",
                text: $viewModel.balanceText,
                keyboard: .numbersAndPunctuation,
                currencyCode: viewModel.currency?.code
            )
            .focused($focus, equals: .balance)
        }
    }

    /// "Balance as of" another moment, never in the future; now when off (`ACC-09`, `GEN-13`).
    @ViewBuilder
    private var balanceDateRows: some View {
        // A switch row as in Settings: its name beside the switch, not above it.
        HStack(spacing: 12) {
            FormRowIcon(systemImage: "clock.arrow.circlepath", tint: .purple)
            Toggle("accountSettings.balanceAsOfOtherDate", isOn: $viewModel.usesBalanceDate)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)

        if viewModel.usesBalanceDate {
            FormRow(label: "accountSettings.balanceDate", systemImage: "calendar", tint: .red, error: viewModel.dateIssue?.message) {
                DatePicker(
                    "accountSettings.balanceDate",
                    selection: $viewModel.balanceDate,
                    in: ...viewModel.latestDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    private func submit() {
        focus = nil
        Task {
            // Back to the Wallet on success (`ACC-12`).
            if await viewModel.submit() {
                Haptics.success()
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        AccountSettingsView(app: .preview, accountID: 3)
    }
    .environment(AppViewModel.preview)
}
