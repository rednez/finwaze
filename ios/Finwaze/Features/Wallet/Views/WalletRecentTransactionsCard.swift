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
            detail: widget.currencyCode.map { Text(verbatim: $0) },
            action: .init(title: "dashboard.recent.all", perform: onOpenTransactions),
            systemImage: "list.bullet",
            tint: .blue
        ) {
            if let currencyCode = widget.currencyCode {
                ChartSettingsMenu(
                    currencyCodes: widget.currencyCodes,
                    currencyCode: currencyCode,
                    onSelectCurrency: widget.selectCurrency
                )
            }
        } content: {
            if let currencyCode = widget.currencyCode {
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
        .loads(widget, dataVersion: dataVersion)
    }
}
