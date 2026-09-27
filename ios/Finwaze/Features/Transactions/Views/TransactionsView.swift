import SwiftUI

/// The Transactions section: the month's expenses, incomes and transfers grouped by day (`TX-01…08`), with the
/// month and its totals on top, the other filters in a sheet and "Add" (`TX-05`). Opening a transaction comes with
/// editing (stage 4) and transfer details (stage 5).
struct TransactionsView: View {
    /// What the list depends on: a change to either reloads it.
    private struct LoadKey: Equatable {
        let filters: TransactionFilters
        let dataVersion: Int
    }

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
            .task(id: LoadKey(filters: viewModel.filters, dataVersion: app.dataVersion)) { await viewModel.load() }
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

/// The month card, the filters in use and a card per day. Filters that match nothing keep all of that in place
/// with a short note, not the empty state (`TX-07`).
private struct TransactionList: View {
    @Bindable var viewModel: TransactionsViewModel
    let transactions: [Transaction]
    let onFilter: () -> Void

    var body: some View {
        let days = TransactionDay.group(transactions)
        ScrollView {
            LazyVStack(spacing: 24) {
                VStack(spacing: 12) {
                    MonthCard(
                        month: viewModel.filters.month,
                        count: transactions.count,
                        totals: TransactionTotals.of(transactions),
                        activeFilters: viewModel.filters.activeCount,
                        onShift: { months in withAnimation(.snappy) { viewModel.filters.shiftMonth(by: months) } },
                        onFilter: onFilter
                    )
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

/// "‹ September 2026 ›" with the filters button, the number of items and — when they can be added up — the month's
/// income and expenses (`GEN-02`, `GEN-14`, `TX-05`).
private struct MonthCard: View {
    let month: Date
    let count: Int
    let totals: TransactionTotals?
    let activeFilters: Int
    let onShift: (Int) -> Void
    let onFilter: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Button("transactions.filters.previousMonth", systemImage: "chevron.left") { onShift(-1) }
                VStack(spacing: 2) {
                    Text(verbatim: title)
                        .font(.title3.weight(.semibold))
                        .contentTransition(.numericText())
                    Text("transactions.count \(count)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
                Button("transactions.filters.nextMonth", systemImage: "chevron.right") { onShift(1) }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)

            // A zero total says nothing (e.g. expenses while filtering incomes), so only non-zero ones show.
            if let totals, totals.income != 0 || totals.expenses != 0 {
                HStack(spacing: 12) {
                    if totals.income != 0 {
                        TotalTile(
                            title: "transactions.summary.income",
                            systemImage: "arrow.down.left",
                            amount: totals.income.formattedSignedAmount(currencyCode: totals.currencyCode),
                            tint: .green
                        )
                    }
                    if totals.expenses != 0 {
                        TotalTile(
                            title: "transactions.summary.expenses",
                            systemImage: "arrow.up.right",
                            amount: totals.expenses.formattedAmount(currencyCode: totals.currencyCode),
                            tint: .orange
                        )
                    }
                }
            }

            Button(action: onFilter) {
                HStack {
                    Label("transactions.filters.title", systemImage: "line.3.horizontal.decrease")
                    Spacer()
                    if activeFilters > 0 {
                        Text(verbatim: activeFilters.formatted())
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(.tint, in: .capsule)
                    }
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .font(.subheadline.weight(.medium))
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityValue(Text("transactions.filters.activeCount \(activeFilters)"))
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 28))
    }

    /// "September 2026"; capitalised, since some languages write months in lowercase ("вересень").
    private var title: String {
        let text = month.formattedMonth()
        return text.prefix(1).uppercased() + text.dropFirst()
    }
}

/// One of the month's totals: a small tinted icon, its name and the amount.
private struct TotalTile: View {
    let title: LocalizedStringKey
    let systemImage: String
    let amount: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .labelStyle(TintedIconLabelStyle(tint: tint))
            Text(verbatim: amount)
                .font(.headline)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(tint.opacity(0.1), in: .rect(cornerRadius: 16))
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
                            .padding(.leading, 68)
                    }
                    TransactionRow(transaction: transaction)
                }
            }
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 22))
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
