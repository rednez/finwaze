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
                onSaved: { app.dataChanged() }
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

#Preview {
    NewTransactionView(app: .preview)
}
