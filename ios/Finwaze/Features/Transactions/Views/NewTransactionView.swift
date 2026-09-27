import SwiftUI

/// "New transaction": an expense or an income (`TX-10…16`, `TX-20…24`, `TX-30`). Success closes the sheet; the list
/// and the Wallet then show the new figures (`TX-15`, `GEN-26`).
struct NewTransactionView: View {
    let app: AppViewModel
    @State private var viewModel: TransactionFormViewModel
    @Environment(\.dismiss) private var dismiss

    init(app: AppViewModel) {
        self.app = app
        _viewModel = State(
            initialValue: TransactionFormViewModel(
                referenceData: app.referenceData,
                preferences: app.preferences,
                repository: app.repositories.transactions,
                onCreated: { app.transactionCreated() }
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Picker("transactionForm.type", selection: $viewModel.type) {
                        Text("transactionType.expense").tag(TransactionType.expense)
                        Text("transactionType.income").tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                    .disabled(viewModel.isSubmitting)

                    TransactionFormFields(viewModel: viewModel, app: app)

                    SubmitButton(title: "transactionForm.create", isLoading: viewModel.isSubmitting, action: submit)
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("transactionForm.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // "Back" without saving (`NAV-05`).
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel", role: .cancel) { dismiss() }
                        .disabled(viewModel.isSubmitting)
                }
            }
            .failureAlert($viewModel.failure, title: "transactionForm.creationFailed")
        }
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }

    private func submit() {
        Task {
            if await viewModel.submit() {
                dismiss()
            }
        }
    }
}

/// Account, amount, category, date and comment. Labels follow the type: "From account" for an expense, "To account"
/// for an income.
private struct TransactionFormFields: View {
    @Bindable var viewModel: TransactionFormViewModel
    let app: AppViewModel

    @FocusState private var focus: Field?
    @State private var isPickingCategory = false

    private enum Field {
        case amount, comment
    }

    private var isExpense: Bool {
        viewModel.type == .expense
    }

    var body: some View {
        VStack(spacing: 16) {
            accountField
            amountField
            categoryField
            dateField
            commentField
        }
        .disabled(viewModel.isSubmitting)
        .sheet(isPresented: $isPickingCategory) {
            CategoryPickerView(type: viewModel.type, app: app, selection: $viewModel.category)
        }
    }

    private var accountField: some View {
        FormField(
            label: isExpense ? "transactionForm.fromAccount" : "transactionForm.toAccount",
            error: viewModel.accountIssue?.message
        ) {
            Menu {
                Picker("transactionForm.account", selection: $viewModel.account) {
                    ForEach(viewModel.accounts) { account in
                        Text(verbatim: "\(account.name) · \(account.currencyCode)").tag(Account?.some(account))
                    }
                }
            } label: {
                PickerRowLabel(
                    value: viewModel.account.map { Text(verbatim: "\($0.name) · \($0.currencyCode)") },
                    placeholder: "transactionForm.accountPlaceholder"
                )
            }
            .accessibilityValue(viewModel.account.map { "\($0.name), \($0.currencyCode)" } ?? "")
        }
    }

    /// The purchase currency is the account's and cannot be changed yet (`TX-21`, `TX-23`); stage 4 adds the choice
    /// together with the charged amount (`TX-22`).
    private var amountField: some View {
        FormField(
            label: isExpense ? "transactionForm.expenseAmount" : "transactionForm.incomeAmount",
            error: viewModel.amountIssue?.message,
            isFocused: focus == .amount
        ) {
            HStack {
                TextField("transactionForm.amountPlaceholder", text: $viewModel.amountText)
                    .keyboardType(.decimalPad)
                    .monospacedDigit()
                    .focused($focus, equals: .amount)
                if let code = viewModel.purchaseCurrencyCode {
                    Text(verbatim: code)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.fill.tertiary, in: .capsule)
                        .accessibilityLabel(Text("transactionForm.currency"))
                        .accessibilityValue(Text(verbatim: code))
                        .accessibilityHint(Text("transactionForm.currencyHint"))
                }
            }
        }
    }

    private var categoryField: some View {
        FormField(label: "transactionForm.category", error: viewModel.categoryIssue?.message) {
            Button {
                focus = nil
                isPickingCategory = true
            } label: {
                PickerRowLabel(
                    value: viewModel.category.map { CategoryLabel(category: $0, group: viewModel.categoryGroup) },
                    placeholder: "transactionForm.categoryPlaceholder"
                )
            }
            .buttonStyle(.plain)
            .accessibilityValue(viewModel.category?.name ?? "")
        }
    }

    private var dateField: some View {
        FormField(label: "transactionForm.date", error: nil) {
            DatePicker(
                "transactionForm.date",
                selection: $viewModel.transactedAt,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var commentField: some View {
        FormField(
            label: "transactionForm.comment",
            error: viewModel.commentIssue?.message,
            isFocused: focus == .comment
        ) {
            TextField("transactionForm.commentPlaceholder", text: $viewModel.comment, axis: .vertical)
                .lineLimit(1...3)
                .focused($focus, equals: .comment)
        }
    }
}

/// A picker field's content: the chosen value, or a placeholder, and an up-down chevron.
private struct PickerRowLabel<Value: View>: View {
    let value: Value?
    let placeholder: LocalizedStringKey

    var body: some View {
        HStack {
            Group {
                if let value {
                    value.foregroundStyle(.primary)
                } else {
                    Text(placeholder).foregroundStyle(.tertiary)
                }
            }
            .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.up.chevron.down")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .contentShape(.rect)
    }
}

/// "Groceries — Food" with the category's colour mark (`TX-11`).
private struct CategoryLabel: View {
    let category: Category
    let group: CategoryGroup?

    var body: some View {
        HStack(spacing: 6) {
            ColorTag(hex: category.color)
            Text(verbatim: category.name)
            if let group {
                Text(verbatim: "— \(group.name)")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NewTransactionView(app: .preview)
}
