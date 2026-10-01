import SwiftUI

/// Account, amount, category, date and comment — shared by "New transaction" and "Edit transaction" (`TX-40`), in
/// grouped rows. Labels follow the type: "From account" for an expense, "To account" for an income. For an expense,
/// the amount's currency can be changed (`TX-21`); when it differs from the account's, "Charged from account" appears
/// right under the amount, with the exchange rate (`TX-22`, `GEN-10`).
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
        VStack(spacing: 20) {
            FormSection {
                accountRow
                amountRow
                if viewModel.showsChargedAmount {
                    chargedAmountRow
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            FormSection {
                categoryRow
                dateRow
            }
            FormSection {
                commentRow
            }
        }
        .disabled(viewModel.isSubmitting)
        .sheet(isPresented: $isPickingCategory) {
            CategoryPickerView(type: viewModel.type, app: app, selection: $viewModel.category)
        }
        .animation(.default, value: viewModel.showsChargedAmount)
    }

    private var accountRow: some View {
        let label: LocalizedStringKey = isExpense ? "transactionForm.fromAccount" : "transactionForm.toAccount"
        return FormRow(label: label, systemImage: "creditcard.fill", tint: .blue, error: viewModel.accountIssue?.message) {
            FormMenuValue(
                value: viewModel.account.map { Text(verbatim: "\($0.name) · \($0.currencyCode)") },
                placeholder: "transactionForm.accountPlaceholder"
            ) {
                Picker("transactionForm.account", selection: $viewModel.account) {
                    ForEach(viewModel.accounts) { account in
                        Text(verbatim: "\(account.name) · \(account.currencyCode)").tag(Account?.some(account))
                    }
                }
            }
            .accessibilityLabel(Text(label))
            .accessibilityValue(viewModel.account.map { "\($0.name), \($0.currencyCode)" } ?? "")
        }
    }

    /// For an income the currency is always the account's, shown as a fixed badge (`TX-30`); for an expense it can
    /// be changed to any of the user's account currencies (`TX-21`).
    private var amountRow: some View {
        let label: LocalizedStringKey = isExpense ? "transactionForm.expenseAmount" : "transactionForm.incomeAmount"
        return FormRow(label: label, systemImage: "banknote.fill", tint: .green, error: viewModel.amountIssue?.message) {
            FormAmountInput(title: label, text: $viewModel.amountText) {
                if isExpense {
                    currencyMenu
                } else if let code = viewModel.purchaseCurrencyCode {
                    CurrencyBadge(code: code)
                        .accessibilityHint(Text("transactionForm.currencyHint"))
                }
            }
            .focused($focus, equals: .amount)
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
                HStack(spacing: 4) {
                    Text(verbatim: code)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2.weight(.bold))
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.tint)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.tint.opacity(0.12), in: .capsule)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("transactionForm.currency"))
            .accessibilityValue(Text(verbatim: code))
        }
    }

    /// "Charged from account", only for a foreign-currency expense (`TX-22`), with the exchange rate (`GEN-10`).
    private var chargedAmountRow: some View {
        FormRow(
            label: "transactionForm.chargedFromAccount",
            systemImage: "arrow.left.arrow.right",
            tint: .indigo,
            note: viewModel.exchangeRateHint.map { Text(verbatim: $0) },
            error: viewModel.chargedAmountIssue?.message
        ) {
            FormAmountInput(title: "transactionForm.chargedFromAccount", text: $viewModel.chargedAmountText, currencyCode: viewModel.account?.currencyCode)
            .focused($focus, equals: .chargedAmount)
        }
    }

    private var categoryRow: some View {
        FormRow(
            label: "transactionForm.category",
            systemImage: "square.grid.2x2.fill",
            tint: .orange,
            error: viewModel.categoryIssue?.message
        ) {
            Button {
                focus = nil
                isPickingCategory = true
            } label: {
                FormValueLabel(
                    value: viewModel.category.map { CategoryLabel(category: $0, group: viewModel.categoryGroup) },
                    placeholder: "transactionForm.categoryPlaceholder"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("transactionForm.category"))
            .accessibilityValue(viewModel.category?.name ?? "")
        }
    }

    private var dateRow: some View {
        FormRow(label: "transactionForm.date", systemImage: "calendar", tint: .red) {
            DatePicker(
                "transactionForm.date",
                selection: $viewModel.transactedAt,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
        }
        // The transaction's own offset while editing, not the device's (`GEN-12`).
        .environment(\.timeZone, viewModel.timeZone)
    }

    private var commentRow: some View {
        FormRow(
            label: "transactionForm.comment",
            systemImage: "text.bubble.fill",
            tint: .gray,
            error: viewModel.commentIssue?.message
        ) {
            TextField("transactionForm.commentPlaceholder", text: $viewModel.comment, axis: .vertical)
                .lineLimit(1...3)
                .focused($focus, equals: .comment)
                .accessibilityLabel(Text("transactionForm.comment"))
        }
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
struct CurrencyBadge: View {
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
