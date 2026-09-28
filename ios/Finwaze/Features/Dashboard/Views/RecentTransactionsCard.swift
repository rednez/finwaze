import SwiftUI

/// "Recent transactions": the three newest in every currency, each opening for editing or its transfer's details,
/// and a link to the whole list (`DASH-06`, `TX-06`).
struct RecentTransactionsCard: View {
    let state: CardState<[Transaction]>
    let onRetry: () -> Void
    let onOpenTransactions: () -> Void

    var body: some View {
        ContentCard(
            title: "dashboard.recent.title",
            action: .init(title: "dashboard.recent.all", perform: onOpenTransactions)
        ) {
            CardStateView(
                state: state,
                placeholder: .recentPlaceholder(count: DashboardViewModel.recentLimit),
                onRetry: onRetry
            ) { transactions in
                if transactions.isEmpty {
                    CardEmptyState(
                        title: "dashboard.recent.empty.title",
                        message: "dashboard.recent.empty.message",
                        actionTitle: "dashboard.recent.open",
                        action: onOpenTransactions
                    )
                } else {
                    RecentTransactionsList(transactions: transactions)
                }
            }
        }
    }
}
