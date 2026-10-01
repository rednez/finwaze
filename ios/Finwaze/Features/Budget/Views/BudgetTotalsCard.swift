import SwiftUI

/// "Monthly budget", or a group's total (`BUD-13`, `BUD-17`): spent against planned on a bar, what is left and the
/// status; without a plan, the way to make one.
struct BudgetTotalsCard: View {
    let title: LocalizedStringKey
    let state: CardState<BudgetTotals>
    let currencyCode: String
    let onRetry: () -> Void
    let onCreateBudget: () -> Void

    var body: some View {
        ContentCard(title: title, systemImage: "chart.pie.fill", style: .prominent) {
            CardStateView(state: state, placeholder: .placeholder, onRetry: onRetry) { totals in
                if totals.hasPlan {
                    BudgetTotalsContent(totals: totals, currencyCode: currencyCode)
                } else {
                    CardEmptyState(
                        title: "budget.totals.empty.title",
                        message: "budget.totals.empty.message",
                        actionTitle: "budget.create",
                        action: onCreateBudget
                    )
                }
            }
        }
    }
}

private struct BudgetTotalsContent: View {
    let totals: BudgetTotals
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    figure("budget.spent", totals.spent, size: .large)
                    Spacer(minLength: 12)
                    figure("budget.planned", totals.planned, size: .medium, alignment: .trailing)
                }
                VStack(alignment: .leading, spacing: 8) {
                    figure("budget.spent", totals.spent, size: .large)
                    figure("budget.planned", totals.planned, size: .medium)
                }
            }

            SpentBar(totals: totals)

            ViewThatFits(in: .horizontal) {
                HStack {
                    remaining
                    Spacer(minLength: 8)
                    BudgetStatusBadge(status: totals.status)
                }
                VStack(alignment: .leading, spacing: 8) {
                    remaining
                    BudgetStatusBadge(status: totals.status)
                }
            }
        }
    }

    private var remaining: some View {
        HStack(spacing: 6) {
            Text("budget.left")
                .foregroundStyle(.secondary)
            Text(verbatim: totals.remaining.formattedAmount(currencyCode: currencyCode))
                .fontWeight(.semibold)
                .foregroundStyle(totals.remaining < 0 ? .red : .primary)
                .monospacedDigit()
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }

    private func figure(
        _ title: LocalizedStringKey,
        _ amount: Decimal,
        size: AmountText.Size,
        alignment: HorizontalAlignment = .leading
    ) -> some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
            AmountText(amount: amount, currencyCode: currencyCode, size: size)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Spent against planned as a bar in the status colour, full once spending reaches the plan.
private struct SpentBar: View {
    let totals: BudgetTotals

    var body: some View {
        let fraction = totals.planned > 0 ? min(totals.spent / totals.planned, 1) : 1
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                Capsule()
                    .fill(totals.status.color)
                    .frame(width: geometry.size.width * fraction.chartValue)
            }
        }
        .frame(height: 10)
        .accessibilityElement()
        .accessibilityLabel(Text("budget.spent"))
        .accessibilityValue(Text(verbatim: share))
    }

    /// "110 %"; only shown with a plan.
    private var share: String {
        guard totals.planned > 0 else { return "" }
        return (totals.spent / totals.planned).formatted(.percent.precision(.fractionLength(0)))
    }
}

private extension BudgetTotals {
    /// Skeleton figures while the totals load (`GEN-23`).
    static let placeholder = BudgetTotals(planned: 12000, spent: 7450)
}
