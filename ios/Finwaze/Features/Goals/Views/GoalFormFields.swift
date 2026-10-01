import SwiftUI

/// Name, target amount, currency and target date (`GOAL-20`), shared by "New goal" and a goal's screen, in grouped
/// rows. The currency is picked only for a new goal; a done or cancelled goal shows everything read-only
/// (`GOAL-22`).
struct GoalFormFields: View {
    @Bindable var viewModel: GoalFormViewModel
    @State private var isPickingCurrency = false
    @FocusState private var focus: Field?

    private enum Field {
        case name, amount
    }

    var body: some View {
        VStack(spacing: 20) {
            FormSection {
                nameRow
                amountRow
                currencyRow
            }
            FormSection {
                dateRow
            }
        }
        .disabled(viewModel.isSubmitting || viewModel.isReadOnly)
        .sheet(isPresented: $isPickingCurrency) {
            CurrencyPicker(currencies: viewModel.currencies, selection: $viewModel.currency)
        }
    }

    private var nameRow: some View {
        FormRow(label: "goals.form.name", systemImage: "target", tint: .green, error: viewModel.nameIssue?.message) {
            TextField("goals.form.namePlaceholder", text: $viewModel.name)
                .textInputAutocapitalization(.sentences)
                .focused($focus, equals: .name)
                .accessibilityLabel(Text("goals.form.name"))
        }
    }

    private var amountRow: some View {
        FormRow(
            label: "goals.form.targetAmount",
            systemImage: "banknote.fill",
            tint: .blue,
            error: viewModel.amountIssue?.message
        ) {
            FormAmountInput(title: "goals.form.targetAmount", text: $viewModel.targetAmountText, currencyCode: viewModel.currencyCode)
            .focused($focus, equals: .amount)
        }
    }

    /// The full directory for a new goal; locked afterwards (`GOAL-20`).
    private var currencyRow: some View {
        FormRow(
            label: "accountForm.currency",
            systemImage: "dollarsign.circle.fill",
            tint: .teal,
            error: viewModel.currencyIssue?.message
        ) {
            Button {
                focus = nil
                isPickingCurrency = true
            } label: {
                FormValueLabel(
                    value: viewModel.currency.map { Text(verbatim: $0.displayName) }
                        ?? viewModel.currencyCode.map { Text(verbatim: $0) },
                    placeholder: "goals.form.selectCurrency",
                    systemImage: viewModel.isEditing ? "lock.fill" : "chevron.right"
                )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isEditing)
            .accessibilityLabel(Text("accountForm.currency"))
            .accessibilityValue(viewModel.currency?.displayName ?? viewModel.currencyCode ?? "")
        }
    }

    /// Required and not in the past; empty for a new goal until picked (`GOAL-20`).
    private var dateRow: some View {
        FormRow(label: "goals.form.targetDate", systemImage: "calendar", tint: .red, error: viewModel.dateIssue?.message) {
            if viewModel.targetDate == nil {
                Button {
                    focus = nil
                    viewModel.targetDate = viewModel.earliestDate
                } label: {
                    FormValueLabel(value: Text?.none, placeholder: "goals.form.selectTargetDate")
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
            }
        }
    }
}
