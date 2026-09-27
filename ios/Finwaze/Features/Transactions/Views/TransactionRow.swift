import SwiftUI

/// One transaction in the list (`TX-02`), in the short form a phone fits: category, group and date, comment, amount.
/// A purchase in another currency also shows the amount charged to the account.
struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                title
                subtitle
                if let comment = transaction.comment {
                    Text(verbatim: comment)
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 4) {
                Text(verbatim: amount)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(amountStyle)
                if transaction.isForeignCurrency {
                    Text(verbatim: transaction.chargedAmount.formattedAmount(currencyCode: transaction.chargedCurrencyCode))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .monospacedDigit()
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }

    /// The category; for a transfer, "Transfer" instead (`TX-02`).
    @ViewBuilder
    private var title: some View {
        HStack(spacing: 6) {
            if transaction.type == .transfer {
                Text("transactions.transfer")
            } else {
                ColorTag(hex: transaction.category.color)
                Text(verbatim: transaction.category.name)
            }
        }
        .font(.body.weight(.medium))
        .lineLimit(1)
    }

    /// The group, or the account for a transfer, and the date in the local time of the transaction (`GEN-12`).
    private var subtitle: some View {
        HStack(spacing: 4) {
            if transaction.type == .transfer {
                Text(verbatim: transaction.accountName)
            } else {
                ColorTag(hex: transaction.group.color)
                Text(verbatim: transaction.group.name)
            }
            Text(verbatim: "·")
                .accessibilityHidden(true)
            Text(verbatim: transaction.transactedAt.formattedTransactionDate(offset: transaction.localOffset))
                .layoutPriority(1)
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }

    private var amount: String {
        let value = transaction.transactionAmount
        let code = transaction.transactionCurrencyCode
        return transaction.type == .income
            ? value.formattedSignedAmount(currencyCode: code)
            : value.formattedAmount(currencyCode: code)
    }

    /// Expenses negative, incomes positive in green, transfers neutral (`GEN-08`).
    private var amountStyle: AnyShapeStyle {
        switch transaction.type {
        case .income: AnyShapeStyle(.green)
        case .transfer: AnyShapeStyle(.secondary)
        case .expense, .internal: AnyShapeStyle(.primary)
        }
    }
}

#Preview {
    List(DemoData.transactions(inMonthOf: .now)) { transaction in
        TransactionRow(transaction: transaction)
    }
}
