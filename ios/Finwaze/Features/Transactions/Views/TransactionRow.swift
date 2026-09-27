import SwiftUI

/// One transaction in a day card (`TX-02`), in the short form a phone fits: a badge in the category's colour, the
/// category with its group and time, the comment and the amount. A purchase in another currency also shows the
/// amount charged to the account. The day is in the card's header. An expense or income opens for editing, a
/// transfer opens its details (`TX-06`, `TRF-07`).
struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        Group {
            if transaction.type == .transfer {
                NavigationLink(value: TransferRoute(transactionID: transaction.id)) {
                    content
                }
            } else {
                NavigationLink(value: TransactionRoute(id: transaction.id)) {
                    content
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var content: some View {
        HStack(spacing: 12) {
            TransactionBadge(transaction: transaction)

            VStack(alignment: .leading, spacing: 2) {
                title
                    .font(.body.weight(.medium))
                Text(verbatim: subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let comment = transaction.comment {
                    Text(verbatim: comment)
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
            }
            .lineLimit(1)

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
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
            .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }

    /// The category; for a transfer, "Transfer" instead (`TX-02`).
    @ViewBuilder
    private var title: some View {
        if transaction.type == .transfer {
            Text("transactions.transfer")
        } else {
            Text(verbatim: transaction.category.name)
        }
    }

    /// "Food · 14:05", or "from Cash · 14:05" / "to Card · 14:05" for a transfer, in the local time of the
    /// transaction (`TX-02`, `TRF-06`, `GEN-12`).
    private var subtitle: String {
        "\(context) · \(transaction.transactedAt.formattedTransactionTime(offset: transaction.localOffset))"
    }

    private var context: String {
        guard transaction.type == .transfer else { return transaction.group.name }
        return transaction.transactionAmount < 0
            ? String(localized: "transactions.transferFrom \(transaction.accountName)")
            : String(localized: "transactions.transferTo \(transaction.accountName)")
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

/// A round badge: the category's initial on a soft tint of its colour (`CAT-10`), or arrows for a transfer.
private struct TransactionBadge: View {
    let transaction: Transaction

    private var color: Color? {
        transaction.type == .transfer ? nil : transaction.category.color.flatMap(Color.init(hex:))
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(color.map { AnyShapeStyle($0.opacity(0.18)) } ?? AnyShapeStyle(.fill.tertiary))
            if transaction.type == .transfer {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.subheadline.weight(.semibold))
            } else {
                Text(verbatim: String(transaction.category.name.prefix(1)).uppercased())
                    .font(.headline)
            }
        }
        .foregroundStyle(color.map { AnyShapeStyle($0) } ?? AnyShapeStyle(.secondary))
        .frame(width: 40, height: 40)
        .accessibilityHidden(true)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 0) {
            ForEach(DemoData.transactions(inMonthOf: .now)) { transaction in
                TransactionRow(transaction: transaction)
            }
        }
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
