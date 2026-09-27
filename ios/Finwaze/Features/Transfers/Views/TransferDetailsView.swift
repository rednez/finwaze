import SwiftUI

/// "Transfer details" (`TRF-07`, `TRF-08`): pushed from the transactions list when either transfer row is tapped.
/// Shows what was sent and received and lets the user delete the transfer; there is no editing.
struct TransferDetailsView: View {
    @State private var viewModel: TransferDetailsViewModel
    @State private var isConfirmingDelete = false
    @Environment(\.dismiss) private var dismiss

    init(app: AppViewModel, transactionID: Int64) {
        _viewModel = State(
            initialValue: TransferDetailsViewModel(
                transactionID: transactionID,
                repository: app.repositories.transfers,
                onDeleted: { app.transferDeleted() }
            )
        )
    }

    var body: some View {
        content
            .navigationTitle("transferDetails.title")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
            .failureAlert($viewModel.deletionFailure, title: "transferDetails.deletionFailed")
            // A destructive confirmation before deleting (`GEN-22`, `Q-01`).
            .confirmationDialog(
                "transferDetails.deleteConfirmTitle",
                isPresented: $isConfirmingDelete,
                titleVisibility: .visible
            ) {
                Button("transferDetails.delete", role: .destructive) {
                    Task {
                        // Back to the list on success (`TRF-08`); a failure stays on screen with an alert.
                        if await viewModel.delete() {
                            dismiss()
                        }
                    }
                }
                Button("common.cancel", role: .cancel) {}
            } message: {
                Text("transferDetails.deleteConfirmMessage")
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
                Label("transferDetails.notFound.title", systemImage: "questionmark.circle")
            } description: {
                Text("transferDetails.notFound.message")
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
        case .loaded(let transfer):
            details(transfer)
        }
    }

    private func details(_ transfer: Transfer) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // In the local time of the transfer, not the device's (`GEN-12`).
                Text(verbatim: transfer.transactedAt.formattedTransactionDate(offset: transfer.localOffset))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TransferSideCard(
                    title: "transferDetails.sent",
                    amount: transfer.sentAmount.formattedAmount(currencyCode: transfer.sent.transactionCurrencyCode),
                    account: String(localized: "transactions.transferFrom \(transfer.sent.accountName)"),
                    exchangeRate: nil
                )

                Image(systemName: "arrow.down.circle.fill")
                    .font(.title)
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)

                TransferSideCard(
                    title: "transferDetails.received",
                    amount: transfer.receivedAmount.formattedAmount(currencyCode: transfer.received.transactionCurrencyCode),
                    account: String(localized: "transactions.transferTo \(transfer.received.accountName)"),
                    exchangeRate: viewModel.exchangeRate.map { $0.formattedExchangeRate(fractionLength: 4...4) }
                )

                Button("transferDetails.delete", systemImage: "trash", role: .destructive) {
                    isConfirmingDelete = true
                }
                .disabled(viewModel.isDeleting)
                .padding(.top, 8)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
    }
}

/// "Sent" or "Received": the amount with its currency, the account and, for the received side, the rate (`TRF-07`).
private struct TransferSideCard: View {
    let title: LocalizedStringKey
    let amount: String
    let account: String
    let exchangeRate: String?

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text(verbatim: amount)
                .font(.title.weight(.semibold))
                .monospacedDigit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(verbatim: account)
                .font(.subheadline)
            if let exchangeRate {
                Text("transferDetails.exchangeRate \(exchangeRate)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        TransferDetailsView(app: .preview, transactionID: 20260950)
    }
    .environment(AppViewModel.preview)
}
