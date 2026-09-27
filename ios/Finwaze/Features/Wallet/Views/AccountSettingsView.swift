import SwiftUI

/// "Account settings" (`ACC-09…12`): pushed from an account card in the Wallet, with its own "Update" and "Delete" —
/// not a sheet, so a plain back button leaves without saving (`NAV-05`).
struct AccountSettingsView: View {
    @State private var viewModel: AccountSettingsViewModel
    @Environment(\.dismiss) private var dismiss

    init(app: AppViewModel, accountID: Int64) {
        _viewModel = State(
            initialValue: AccountSettingsViewModel(
                accountID: accountID,
                referenceData: app.referenceData,
                repository: app.repositories.wallet,
                onChanged: { await app.accountUpdated() },
                onDeleted: { await app.accountDeleted() }
            )
        )
    }

    var body: some View {
        content
            .navigationTitle("accountSettings.title")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            // A neutral spinner while the fresh copy loads (`GEN-23`).
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
        case .notFound:
            ContentUnavailableView {
                Label("accountSettings.notFound.title", systemImage: "questionmark.circle")
            } description: {
                Text("accountSettings.notFound.message")
            } actions: {
                Button("accountSettings.notFound.back") { dismiss() }
                    .buttonStyle(.glassProminent)
            }
        case .failed:
            ContentUnavailableView {
                Label("error.generic.title", systemImage: "exclamationmark.triangle")
            } description: {
                Text("error.generic.message")
            } actions: {
                Button("common.retry", systemImage: "arrow.clockwise") {
                    Task { await viewModel.load() }
                }
                .buttonStyle(.glassProminent)
            }
        case .loaded:
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
            VStack(spacing: 24) {
                if !viewModel.canDelete {
                    // Why the currency and "Delete" are unavailable (`ACC-10`, `ACC-11`).
                    Label("accountSettings.lockedHint", systemImage: "info.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(spacing: 16) {
                    nameField
                    currencyField
                    balanceField
                    balanceDateFields
                }
                .disabled(viewModel.isSubmitting || viewModel.isDeleting)
                .animation(.default, value: viewModel.usesBalanceDate)

                SubmitButton(title: "accountSettings.update", isLoading: viewModel.isSubmitting, action: submit)

                Button("accountSettings.delete", systemImage: "trash", role: .destructive) {
                    isConfirmingDelete = true
                }
                .disabled(!viewModel.canDelete || viewModel.isSubmitting || viewModel.isDeleting)
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground))
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
                        dismiss()
                    }
                }
            }
            Button("common.cancel", role: .cancel) {}
        } message: {
            Text("accountSettings.deleteConfirmMessage \(viewModel.details?.name ?? "")")
        }
    }

    private var nameField: some View {
        FormField(label: "accountForm.name", error: viewModel.nameIssue?.message, isFocused: focus == .name) {
            TextField("accountForm.namePlaceholder", text: $viewModel.name)
                .textInputAutocapitalization(.sentences)
                .focused($focus, equals: .name)
        }
    }

    /// The full directory while the account has no transactions; locked otherwise (`ACC-10`).
    private var currencyField: some View {
        FormField(label: "accountForm.currency", error: viewModel.currencyIssue?.message) {
            Button {
                focus = nil
                isPickingCurrency = true
            } label: {
                HStack {
                    Text(verbatim: viewModel.currency?.displayName ?? "")
                        .foregroundStyle(viewModel.isCurrencyEditable ? .primary : .secondary)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: viewModel.isCurrencyEditable ? "chevron.up.chevron.down" : "lock")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.isCurrencyEditable)
            .accessibilityValue(viewModel.currency?.displayName ?? "")
        }
    }

    /// May be negative, so the keyboard has a minus (`ACC-09`).
    private var balanceField: some View {
        FormField(
            label: "accountSettings.balance",
            error: viewModel.balanceIssue?.message,
            isFocused: focus == .balance
        ) {
            HStack {
                TextField("accountSettings.balancePlaceholder", text: $viewModel.balanceText)
                    .keyboardType(.numbersAndPunctuation)
                    .monospacedDigit()
                    .focused($focus, equals: .balance)
                if let code = viewModel.currency?.code {
                    CurrencyBadge(code: code)
                }
            }
        }
    }

    /// "Balance as of" another moment, never in the future; now when off (`ACC-09`, `GEN-13`).
    @ViewBuilder
    private var balanceDateFields: some View {
        Toggle("accountSettings.balanceAsOfOtherDate", isOn: $viewModel.usesBalanceDate)
            .padding(.horizontal, 4)

        if viewModel.usesBalanceDate {
            FormField(label: "accountSettings.balanceDate", error: viewModel.dateIssue?.message) {
                DatePicker(
                    "accountSettings.balanceDate",
                    selection: $viewModel.balanceDate,
                    in: ...viewModel.latestDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    private func submit() {
        focus = nil
        Task {
            // Back to the Wallet on success (`ACC-12`).
            if await viewModel.submit() {
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
