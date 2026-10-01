import SwiftUI

/// Name and currency of a new account, shared by onboarding and "New account" (`ONB-02`, `ACC-07`).
struct AccountFormFields: View {
    @Bindable var viewModel: AccountFormViewModel
    let currencies: [Currency]
    var onSubmit: () -> Void = {}

    @FocusState private var isNameFocused: Bool
    @State private var isPickingCurrency = false

    var body: some View {
        FormSection {
            FormRow(label: "accountForm.name", systemImage: "creditcard.fill", tint: .blue, error: viewModel.nameIssue?.message) {
                TextField("accountForm.namePlaceholder", text: $viewModel.name)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.next)
                    .focused($isNameFocused)
                    .accessibilityLabel(Text("accountForm.name"))
                    .onSubmit {
                        if viewModel.currency == nil {
                            isPickingCurrency = true
                        } else {
                            onSubmit()
                        }
                    }
            }

            FormRow(
                label: "accountForm.currency",
                systemImage: "banknote.fill",
                tint: .green,
                error: viewModel.currencyIssue?.message
            ) {
                Button {
                    isNameFocused = false
                    isPickingCurrency = true
                } label: {
                    FormValueLabel(
                        value: viewModel.currency.map { Text(verbatim: $0.displayName) },
                        placeholder: "accountForm.currencyPlaceholder"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("accountForm.currency"))
                .accessibilityValue(viewModel.currency?.displayName ?? "")
            }
        }
        .disabled(viewModel.isSubmitting)
        .sheet(isPresented: $isPickingCurrency) {
            CurrencyPicker(currencies: currencies, selection: $viewModel.currency)
        }
    }
}

#Preview {
    AccountFormFields(
        viewModel: AccountFormViewModel(repository: DemoReferenceDataRepository()) { _ in },
        currencies: DemoData.currencies
    )
    .padding()
}
