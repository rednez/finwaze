import SwiftUI

/// "Edit transaction" (`TX-06`, `TX-40…42`): pushed from the transactions list, with its own "Save changes" and
/// "Delete" — not a sheet, so a plain back button leaves without saving (`NAV-05`).
struct EditTransactionView: View {
    let app: AppViewModel
    @State private var viewModel: EditTransactionViewModel
    @Environment(\.dismiss) private var dismiss

    init(app: AppViewModel, transactionID: Int64) {
        self.app = app
        _viewModel = State(
            initialValue: EditTransactionViewModel(
                transactionID: transactionID,
                referenceData: app.referenceData,
                preferences: app.preferences,
                repository: app.repositories.transactions,
                onUpdated: { app.transactionUpdated() },
                onDeleted: { app.transactionDeleted() }
            )
        )
    }

    var body: some View {
        content
            .navigationTitle("transactionForm.editTitle")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
            .overlay(alignment: .top) {
                if viewModel.didSave {
                    SuccessBanner(message: "transactionForm.updateSucceeded") { viewModel.didSave = false }
                }
            }
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
                Label("transactionForm.notFound.title", systemImage: "questionmark.circle")
            } description: {
                Text("transactionForm.notFound.message")
            } actions: {
                Button("transactionForm.notFound.back") { dismiss() }
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
            if let formViewModel = viewModel.formViewModel {
                EditTransactionForm(app: app, viewModel: viewModel, formViewModel: formViewModel)
            }
        }
    }
}

/// The shared form fields plus "Save changes" and "Delete" — split out so `@Bindable` can observe both view models.
private struct EditTransactionForm: View {
    let app: AppViewModel
    @Bindable var viewModel: EditTransactionViewModel
    @Bindable var formViewModel: TransactionFormViewModel
    @State private var isConfirmingDelete = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                TransactionFormFields(viewModel: formViewModel, app: app)

                SubmitButton(
                    title: "transactionForm.saveChanges",
                    isLoading: formViewModel.isSubmitting,
                    action: submit
                )

                Button("transactionForm.delete", systemImage: "trash", role: .destructive) {
                    isConfirmingDelete = true
                }
                .disabled(formViewModel.isSubmitting || viewModel.isDeleting)
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground))
        .failureAlert($formViewModel.failure, title: "transactionForm.updateFailed")
        .failureAlert($viewModel.deletionFailure, title: "transactionForm.deletionFailed")
        // A destructive confirmation before deleting (`GEN-22`, `Q-01`).
        .confirmationDialog(
            "transactionForm.deleteConfirmTitle",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button("transactionForm.delete", role: .destructive) {
                Task {
                    // Back to the list on success (`TX-41`); a failure stays on screen with an alert.
                    if await viewModel.delete() {
                        dismiss()
                    }
                }
            }
            Button("common.cancel", role: .cancel) {}
        }
    }

    private func submit() {
        Task {
            if await formViewModel.submit() {
                return
            }
            viewModel.applyNotFoundIfNeeded()
        }
    }
}
