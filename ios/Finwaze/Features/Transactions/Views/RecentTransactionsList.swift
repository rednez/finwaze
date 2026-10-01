import SwiftUI

/// A few recent transactions for a card, each with its date and opening for editing or its transfer's details
/// (`DASH-06`, `ACC-04`, `TX-06`).
struct RecentTransactionsList: View {
    let transactions: [Transaction]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(transactions) { transaction in
                if transaction.id != transactions.first?.id {
                    Divider()
                        .padding(.leading, 70)
                }
                TransactionRow(transaction: transaction, showsDate: true)
            }
        }
        // The rows bring their own side padding; line them up with the card's title.
        .padding(.horizontal, -16)
    }
}

extension [Transaction] {
    /// Skeleton rows while recent transactions load (`GEN-23`): last month's demo ones, of which there are always
    /// enough.
    static func recentPlaceholder(count: Int) -> [Transaction] {
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
        return Array(DemoData.transactions(inMonthOf: lastMonth).prefix(count))
    }
}
