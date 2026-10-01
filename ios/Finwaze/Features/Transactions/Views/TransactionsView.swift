import SwiftUI

/// The Transactions section: the month's expenses, incomes and transfers grouped by day (`TX-01…08`), with the
/// month and its totals on top, the other filters in a sheet and "Add" (`TX-05`). Opening a transaction comes with
/// editing (stage 4) and transfer details (stage 5).
struct TransactionsView: View {
    let app: AppViewModel
    /// "New transaction" is open; set by the section's "+" or the empty state.
    @Binding var isAdding: Bool
    // Kept by the tab for the whole session, so the filters survive switching tabs (`TX-08`).
    @State private var viewModel: TransactionsViewModel
    @State private var isFiltering = false

    init(app: AppViewModel, isAdding: Binding<Bool>) {
        self.app = app
        _isAdding = isAdding
        _viewModel = State(
            initialValue: TransactionsViewModel(repository: app.repositories.transactions, referenceData: app.referenceData)
        )
    }

    var body: some View {
        content
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $isAdding) {
                NewTransactionView(app: app)
            }
            .sheet(isPresented: $isFiltering) {
                TransactionFiltersSheet(viewModel: viewModel)
            }
            // New data (a transaction, category, account) reloads the list as well as a filter change (`GEN-26`).
            .task(for: viewModel.filters, dataVersion: app.dataVersion) {
                await viewModel.load(dataVersion: app.dataVersion)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            TransactionList(viewModel: viewModel, transactions: Transaction.placeholders, onFilter: {})
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
            TransactionList(viewModel: viewModel, transactions: transactions) { isFiltering = true }
                .refreshable { await viewModel.load() }
        case .failed:
            ScreenErrorView(onRetry: { Task { await viewModel.load() } })
        }
    }
}

/// The month and its item count with the filters button, the month's totals, the filters in use and a card per day.
/// The month is changed in the filters sheet. Filters that match nothing keep all of that in place with a short note,
/// not the empty state (`TX-07`).
private struct TransactionList: View {
    @Bindable var viewModel: TransactionsViewModel
    let transactions: [Transaction]
    let onFilter: () -> Void

    var body: some View {
        let days = TransactionDay.group(transactions)
        ScrollView {
            LazyVStack(spacing: 24) {
                VStack(spacing: 14) {
                    FilterSummaryBar(
                        title: viewModel.filters.month.title,
                        details: Text("transactions.count \(transactions.count)"),
                        activeCount: viewModel.filters.activeCount,
                        onFilter: onFilter
                    )
                    .padding(.horizontal, 16)

                    MonthTotals(totals: TransactionTotals.of(transactions))
                        .padding(.horizontal, 16)

                    ActiveFilterChips(viewModel: viewModel)
                }

                if days.isEmpty {
                    ContentUnavailableView {
                        Label("transactions.noMatches.title", systemImage: "line.3.horizontal.decrease.circle")
                    } description: {
                        Text("transactions.noMatches.message")
                    }
                } else {
                    ForEach(days) { day in
                        DaySection(day: day)
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 32)
            .animation(.snappy, value: transactions)
        }
    }
}

/// The month's income and expenses, when they can be added up (`GEN-02`, `TX-05`).
private struct MonthTotals: View {
    let totals: TransactionTotals?

    var body: some View {
        // A zero total says nothing (e.g. expenses while filtering incomes), so only non-zero ones show.
        if let totals, totals.income != 0 || totals.expenses != 0 {
            HStack(spacing: 12) {
                if totals.income != 0 {
                    TotalTile(
                        title: "transactions.summary.income",
                        systemImage: "arrow.down.left",
                        amount: totals.income,
                        currencyCode: totals.currencyCode,
                        isSigned: true,
                        tint: .green
                    )
                }
                if totals.expenses != 0 {
                    TotalTile(
                        title: "transactions.summary.expenses",
                        systemImage: "arrow.up.right",
                        amount: totals.expenses,
                        currencyCode: totals.currencyCode,
                        tint: .orange
                    )
                }
            }
        }
    }
}

/// One of the month's totals: a small tinted icon, its name and the amount.
private struct TotalTile: View {
    let title: LocalizedStringKey
    let systemImage: String
    let amount: Decimal
    let currencyCode: String
    var isSigned = false
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .labelStyle(TintedIconLabelStyle(tint: tint))
            AmountText(amount: amount, currencyCode: currencyCode, size: .medium, isSigned: isSigned)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background { CardBackground() }
        .accessibilityElement(children: .combine)
    }
}

private struct TintedIconLabelStyle: LabelStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            configuration.icon
                .font(.caption2.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 20, height: 20)
                .background(tint.opacity(0.18), in: .circle)
            configuration.title
        }
    }
}

/// A day header — "Today", "Yesterday" or "Friday, 25 September" with the day's balance when it adds up — and the
/// day's transactions in one card.
private struct DaySection: View {
    let day: TransactionDay

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                title
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if let totals = TransactionTotals.of(day.transactions) {
                    Text(verbatim: totals.net.formattedSignedAmount(currencyCode: totals.currencyCode))
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
            .padding(.horizontal, 20)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                ForEach(Array(day.transactions.enumerated()), id: \.element.id) { index, transaction in
                    if index > 0 {
                        Divider()
                            .padding(.leading, 70)
                    }
                    TransactionRow(transaction: transaction)
                }
            }
            .background { CardBackground() }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var title: some View {
        let today = Date.now.isoDateString()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)?.isoDateString()
        switch day.id {
        case today: Text("transactions.today")
        case yesterday: Text("transactions.yesterday")
        default: Text(verbatim: day.first.transactedAt.formattedTransactionDay(offset: day.first.localOffset))
        }
    }
}

private extension Transaction {
    /// Skeleton rows while the list loads (`GEN-23`).
    static let placeholders = DemoData.transactions(inMonthOf: .now).prefix(6).map { $0 }
}

#Preview {
    NavigationStack {
        TransactionsView(app: .preview, isAdding: .constant(false))
    }
    .environment(AppViewModel.preview)
}
