import SwiftUI

/// Name, target amount, target date and currency (`GOAL-20`), shared by "New goal" and a goal's screen. The currency
/// is picked only for a new goal; a done or cancelled goal shows everything read-only (`GOAL-22`).
struct GoalFormFields: View {
    @Bindable var viewModel: GoalFormViewModel
    @State private var isPickingCurrency = false
    @FocusState private var focus: Field?

    private enum Field {
        case name, amount
    }

    var body: some View {
        VStack(spacing: 16) {
            nameField
            amountField
            dateField
            currencyField
        }
        .disabled(viewModel.isSubmitting || viewModel.isReadOnly)
        .sheet(isPresented: $isPickingCurrency) {
            CurrencyPicker(currencies: viewModel.currencies, selection: $viewModel.currency)
        }
    }

    private var nameField: some View {
        FormField(label: "goals.form.name", error: viewModel.nameIssue?.message, isFocused: focus == .name) {
            TextField("goals.form.namePlaceholder", text: $viewModel.name)
                .textInputAutocapitalization(.sentences)
                .focused($focus, equals: .name)
        }
    }

    private var amountField: some View {
        FormField(label: "goals.form.targetAmount", error: viewModel.amountIssue?.message, isFocused: focus == .amount) {
            HStack {
                TextField("goals.form.targetAmountPlaceholder", text: $viewModel.targetAmountText)
                    .keyboardType(.decimalPad)
                    .monospacedDigit()
                    .focused($focus, equals: .amount)
                if let code = viewModel.currencyCode {
                    CurrencyBadge(code: code)
                }
            }
        }
    }

    /// Required and not in the past; empty for a new goal until picked (`GOAL-20`).
    private var dateField: some View {
        FormField(label: "goals.form.targetDate", error: viewModel.dateIssue?.message) {
            if viewModel.targetDate == nil {
                Button {
                    focus = nil
                    viewModel.targetDate = viewModel.earliestDate
                } label: {
                    PickerRowLabel(value: Text?.none, placeholder: "goals.form.selectTargetDate")
                }
                .buttonStyle(.plain)
            } else {
                DatePicker(
                    "goals.form.targetDate",
                    selection: Binding(
                        get: { viewModel.targetDate ?? viewModel.earliestDate },
                        set: { viewModel.targetDate = $0 }
                    ),
                    in: viewModel.earliestDate...,
                    displayedComponents: .date
                )
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    /// The full directory for a new goal; locked afterwards (`GOAL-20`).
    private var currencyField: some View {
        FormField(label: "accountForm.currency", error: viewModel.currencyIssue?.message) {
            Button {
                focus = nil
                isPickingCurrency = true
            } label: {
                HStack {
                    Group {
                        if let currency = viewModel.currency {
                            Text(verbatim: currency.displayName)
                        } else if let code = viewModel.currencyCode {
                            Text(verbatim: code)
                        } else {
                            Text("goals.form.selectCurrency").foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(viewModel.isEditing ? .secondary : .primary)
                    .lineLimit(1)
                    Spacer()
                    Image(systemName: viewModel.isEditing ? "lock" : "chevron.up.chevron.down")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isEditing)
            .accessibilityValue(viewModel.currency?.displayName ?? viewModel.currencyCode ?? "")
        }
    }
}
