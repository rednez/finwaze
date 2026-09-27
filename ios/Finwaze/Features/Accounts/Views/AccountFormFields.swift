import SwiftUI

/// Name and currency of a new account, shared by onboarding and "New account" (`ONB-02`, `ACC-07`).
struct AccountFormFields: View {
    @Bindable var viewModel: AccountFormViewModel
    let currencies: [Currency]
    var onSubmit: () -> Void = {}

    @FocusState private var isNameFocused: Bool
    @State private var isPickingCurrency = false

    var body: some View {
        VStack(spacing: 16) {
            FormField(
                label: "accountForm.name",
                error: viewModel.nameIssue?.message,
                isFocused: isNameFocused
            ) {
                TextField("accountForm.namePlaceholder", text: $viewModel.name)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.next)
                    .focused($isNameFocused)
                    .onSubmit {
                        if viewModel.currency == nil {
                            isPickingCurrency = true
                        } else {
                            onSubmit()
                        }
                    }
            }

            FormField(
                label: "accountForm.currency",
                error: viewModel.currencyIssue?.message
            ) {
                Button {
                    isNameFocused = false
                    isPickingCurrency = true
                } label: {
                    HStack {
                        if let currency = viewModel.currency {
                            Text(verbatim: currency.displayName)
                                .foregroundStyle(.primary)
                        } else {
                            Text("accountForm.currencyPlaceholder")
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
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
