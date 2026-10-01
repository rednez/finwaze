import SwiftUI

/// "New account" from the Wallet (`ACC-07`). Success closes the sheet; the Wallet then shows the account
/// with a zero balance, since reference data was reloaded (`GEN-26`).
struct NewAccountView: View {
    let currencies: [Currency]
    @State private var viewModel: AccountFormViewModel
    @Environment(\.dismiss) private var dismiss

    init(app: AppViewModel) {
        currencies = app.referenceData.currencies
        _viewModel = State(
            initialValue: AccountFormViewModel(repository: app.repositories.accounts, onCreated: app.accountCreated)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                AccountFormFields(viewModel: viewModel, currencies: currencies, onSubmit: submit)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("wallet.newAccount.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel", role: .cancel) { dismiss() }
                        .disabled(viewModel.isSubmitting)
                }
                FormConfirmItem(title: "wallet.newAccount.submit", isSubmitting: viewModel.isSubmitting, action: submit)
            }
            .failureAlert($viewModel.failure, title: "wallet.newAccount.creationFailed")
        }
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }

    private func submit() {
        Task {
            if await viewModel.submit() {
                Haptics.success()
                dismiss()
            }
        }
    }
}

#Preview {
    NewAccountView(app: .preview)
}
