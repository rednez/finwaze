import SwiftUI

/// "Recent transactions": the three newest in every currency, each opening for editing or its transfer's details,
/// and a link to the whole list (`DASH-06`, `TX-06`).
struct RecentTransactionsCard: View {
    let state: CardState<[Transaction]>
    let onRetry: () -> Void
    let onOpenTransactions: () -> Void

    var body: some View {
        DashboardCard(
            title: "dashboard.recent.title",
            action: .init(title: "dashboard.recent.all", perform: onOpenTransactions)
        ) {
            CardStateView(state: state, placeholder: .placeholder, onRetry: onRetry) { transactions in
                if transactions.isEmpty {
                    CardEmptyState(
                        title: "dashboard.recent.empty.title",
                        message: "dashboard.recent.empty.message",
                        actionTitle: "dashboard.recent.open",
                        action: onOpenTransactions
                    )
                } else {
                    VStack(spacing: 0) {
                        ForEach(transactions) { transaction in
                            if transaction.id != transactions.first?.id {
                                Divider()
                                    .padding(.leading, 68)
                            }
                            TransactionRow(transaction: transaction, showsDate: true)
                        }
                    }
                    // The rows bring their own side padding; line them up with the card's title.
                    .padding(.horizontal, -16)
                }
            }
        }
    }
}

private extension [Transaction] {
    /// Skeleton rows while the transactions load (`GEN-23`): last month's demo ones, of which there are always enough.
    static var placeholder: [Transaction] {
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
        return Array(DemoData.transactions(inMonthOf: lastMonth).prefix(DashboardViewModel.recentLimit))
    }
}
