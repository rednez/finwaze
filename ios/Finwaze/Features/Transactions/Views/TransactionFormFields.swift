import SwiftUI

/// Account, amount, category, date and comment — shared by "New transaction" and "Edit transaction" (`TX-40`).
/// Labels follow the type: "From account" for an expense, "To account" for an income. For an expense, the amount's
/// currency can be changed (`TX-21`); when it differs from the account's, a "Charged from account" field appears
/// (`TX-22`).
struct TransactionFormFields: View {
    @Bindable var viewModel: TransactionFormViewModel
    let app: AppViewModel

    @FocusState private var focus: Field?
    @State private var isPickingCategory = false

    private enum Field {
        case amount, chargedAmount, comment
    }

    private var isExpense: Bool {
        viewModel.type == .expense
    }

    var body: some View {
        VStack(spacing: 16) {
            accountField
            amountField
            chargedAmountField
            categoryField
            dateField
            commentField
        }
        .disabled(viewModel.isSubmitting)
        .sheet(isPresented: $isPickingCategory) {
            CategoryPickerView(type: viewModel.type, app: app, selection: $viewModel.category)
        }
        .animation(.default, value: viewModel.showsChargedAmount)
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

    /// For an income the currency is always the account's, shown as a fixed badge (`TX-30`); for an expense it can
    /// be changed to any of the user's account currencies (`TX-21`).
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
                if isExpense {
                    currencyMenu
                } else if let code = viewModel.purchaseCurrencyCode {
                    CurrencyBadge(code: code)
                        .accessibilityHint(Text("transactionForm.currencyHint"))
                }
            }
        }
    }

    @ViewBuilder
    private var currencyMenu: some View {
        if let code = viewModel.purchaseCurrencyCode {
            Menu {
                Picker("transactionForm.currency", selection: $viewModel.purchaseCurrencyCode) {
                    ForEach(viewModel.purchaseCurrencyCodes, id: \.self) { code in
                        Text(verbatim: code).tag(String?.some(code))
                    }
                }
            } label: {
                CurrencyBadge(code: code)
            }
            .accessibilityLabel(Text("transactionForm.currency"))
        }
    }

    /// "Charged from account", only for a foreign-currency expense (`TX-22`); shows the exchange rate below it
    /// (`GEN-10`).
    @ViewBuilder
    private var chargedAmountField: some View {
        if viewModel.showsChargedAmount {
            VStack(alignment: .leading, spacing: 6) {
                FormField(
                    label: "transactionForm.chargedFromAccount",
                    error: viewModel.chargedAmountIssue?.message,
                    isFocused: focus == .chargedAmount
                ) {
                    HStack {
                        TextField("transactionForm.amountPlaceholder", text: $viewModel.chargedAmountText)
                            .keyboardType(.decimalPad)
                            .monospacedDigit()
                            .focused($focus, equals: .chargedAmount)
                        if let code = viewModel.account?.currencyCode {
                            CurrencyBadge(code: code)
                        }
                    }
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
        // The transaction's own offset while editing, not the device's (`GEN-12`).
        .environment(\.timeZone, viewModel.timeZone)
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
struct PickerRowLabel<Value: View>: View {
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
struct CategoryLabel: View {
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

/// A currency code in a small capsule, next to an amount field.
private struct CurrencyBadge: View {
    let code: String

    var body: some View {
        Text(verbatim: code)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.fill.tertiary, in: .capsule)
    }
}

#Preview {
    NewTransactionView(app: .preview)
}
