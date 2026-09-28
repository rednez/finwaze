import SwiftUI

/// "Recent transactions": the three newest in a purchase currency, each opening for editing or its transfer's
/// details, and a link to the whole list (`ACC-04`, `TX-06`).
struct WalletRecentTransactionsCard: View {
    let widget: WalletWidgetViewModel<[Transaction]>
    let dataVersion: Int
    let onOpenTransactions: () -> Void
    let onAddTransaction: () -> Void

    var body: some View {
        ContentCard(
            title: "dashboard.recent.title",
            action: .init(title: "dashboard.recent.all", perform: onOpenTransactions)
        ) {
            if let currencyCode = widget.currencyCode {
                VStack(alignment: .leading, spacing: 12) {
                    WalletWidgetFilterBar(widget: widget, currencyCode: currencyCode, showsMonth: false)
                    CardStateView(
                        state: widget.state,
                        placeholder: .recentPlaceholder(count: WalletRecentTransactions.limit),
                        onRetry: { Task { await widget.refresh() } }
                    ) { transactions in
                        if transactions.isEmpty {
                            CardEmptyState(
                                title: "wallet.recent.empty.title \(currencyCode)",
                                message: "dashboard.recent.empty.message",
                                actionTitle: "transactions.add",
                                action: onAddTransaction
                            )
                        } else {
                            RecentTransactionsList(transactions: transactions)
                        }
                    }
                }
            }
        }
        .loads(widget, dataVersion: dataVersion)
    }
}
