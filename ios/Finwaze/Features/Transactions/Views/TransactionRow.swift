import SwiftUI

/// One transaction in a day card (`TX-02`), in the short form a phone fits: a badge in the category's colour, the
/// category with its group and time, the comment and the amount. A purchase in another currency also shows the
/// amount charged to the account. The day is in the card's header. An expense or income opens for editing, a
/// transfer opens its details (`TX-06`, `TRF-07`). Outside a day card, e.g. on the Dashboard, the row shows the date
/// too (`DASH-06`).
struct TransactionRow: View {
    let transaction: Transaction
    /// The date besides the time, for a row outside a day card.
    var showsDate = false

    var body: some View {
        Group {
            if transaction.type == .transfer {
                NavigationLink(value: TransferRoute(transactionID: transaction.id)) {
                    content
                }
                .zoomSource(ZoomID.transfer(transaction.id))
            } else {
                NavigationLink(value: TransactionRoute(id: transaction.id)) {
                    content
                }
                .zoomSource(ZoomID.transaction(transaction.id))
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
                    .fontDesign(.rounded)
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
    /// transaction (`TX-02`, `TRF-06`, `GEN-12`); with `showsDate`, "Food · 25 Sep, 14:05".
    private var subtitle: String {
        let offset = transaction.localOffset
        let moment = showsDate
            ? transaction.transactedAt.formattedTransactionShortDate(offset: offset)
            : transaction.transactedAt.formattedTransactionTime(offset: offset)
        return "\(context) · \(moment)"
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

/// A badge: the category's initial on a soft tint of its colour (`CAT-10`) — the brand's when the category has none —
/// or arrows for a transfer.
private struct TransactionBadge: View {
    let transaction: Transaction
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 42

    private var color: Color {
        if transaction.type == .transfer { return .blue }
        return transaction.category.color.flatMap(Color.init(hex:)) ?? .accentColor
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.26), color.opacity(0.14)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            if transaction.type == .transfer {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.subheadline.weight(.bold))
            } else {
                Text(verbatim: String(transaction.category.name.prefix(1)).uppercased())
                    .font(.headline.weight(.bold))
                    .fontDesign(.rounded)
            }
        }
        .foregroundStyle(color)
        .frame(width: size, height: size)
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
        .background { CardBackground() }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
