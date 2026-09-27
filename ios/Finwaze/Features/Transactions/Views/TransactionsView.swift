import SwiftUI

/// The Transactions section: the month's expenses, incomes and transfers with filters (`TX-01…08`) and "Add"
/// (`TX-05`). Opening a transaction comes with editing (stage 4) and transfer details (stage 5).
struct TransactionsView: View {
    /// What the list depends on: a change to either reloads it.
    private struct LoadKey: Equatable {
        let filters: TransactionFilters
        let dataVersion: Int
    }

    let app: AppViewModel
    // Kept by the tab for the whole session, so the filters survive switching tabs (`TX-08`).
    @State private var viewModel: TransactionsViewModel
    @State private var isAdding = false

    init(app: AppViewModel) {
        self.app = app
        _viewModel = State(
            initialValue: TransactionsViewModel(repository: app.repositories.transactions, referenceData: app.referenceData)
        )
    }

    var body: some View {
        content
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("transactions.add", systemImage: "plus") { isAdding = true }
                }
            }
            .sheet(isPresented: $isAdding) {
                NewTransactionView(app: app)
            }
            // New data (a transaction, category, account) reloads the list as well as a filter change (`GEN-26`).
            .task(id: LoadKey(filters: viewModel.filters, dataVersion: app.dataVersion)) { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            TransactionList(viewModel: viewModel, transactions: Transaction.placeholders)
                .redacted(reason: .placeholder)
                .allowsHitTesting(false)
                .accessibilityLabel(Text("common.loading"))
        case .empty:
            ContentUnavailableView {
                Label("transactions.empty.title", systemImage: "list.bullet.rectangle")
            } description: {
                Text("transactions.empty.message")
            } actions: {
                Button("transactions.empty.add", systemImage: "plus") { isAdding = true }
                    .buttonStyle(.glassProminent)
            }
        case .loaded(let transactions):
            TransactionList(viewModel: viewModel, transactions: transactions)
                .refreshable { await viewModel.load() }
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
        }
    }
}

/// The filters and the "N items" counter above the rows (`TX-03`, `TX-05`). Filters that match nothing leave the
/// filters in place with a short note, not the empty state (`TX-07`).
private struct TransactionList: View {
    let viewModel: TransactionsViewModel
    let transactions: [Transaction]

    var body: some View {
        List {
            Section {
                if transactions.isEmpty {
                    ContentUnavailableView {
                        Label("transactions.noMatches.title", systemImage: "line.3.horizontal.decrease.circle")
                    } description: {
                        Text("transactions.noMatches.message")
                    }
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
            } header: {
                VStack(alignment: .leading, spacing: 8) {
                    TransactionFiltersBar(viewModel: viewModel)
                        .padding(.horizontal, -20)
                    Text("transactions.count \(transactions.count)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }
                .padding(.bottom, 4)
            }
        }
        .listStyle(.plain)
    }
}

private extension Transaction {
    /// Skeleton rows while the list loads (`GEN-23`).
    static let placeholders = DemoData.transactions(inMonthOf: .now).prefix(6).map { $0 }
}

#Preview {
    NavigationStack {
        TransactionsView(app: .preview)
    }
    .environment(AppViewModel.preview)
}
