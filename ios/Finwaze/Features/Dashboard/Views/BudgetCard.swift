import Charts
import SwiftUI

/// "Budget": this month's plan in the primary currency by category, as a ring with the total in the middle
/// (`DASH-05`).
struct BudgetCard: View {
    let state: CardState<BudgetSummary>
    let currencyCode: String
    let onRetry: () -> Void
    let onOpenBudget: () -> Void

    var body: some View {
        ContentCard(title: "dashboard.budget.title") {
            CardStateView(state: state, placeholder: .placeholder, onRetry: onRetry) { summary in
                if summary.slices.isEmpty {
                    CardEmptyState(
                        title: "dashboard.budget.empty.title",
                        message: "dashboard.budget.empty.message",
                        actionTitle: "dashboard.budget.open",
                        action: onOpenBudget
                    )
                } else {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 20) {
                            BudgetRing(summary: summary, currencyCode: currencyCode)
                            BudgetLegend(slices: summary.slices, currencyCode: currencyCode)
                        }
                        VStack(spacing: 16) {
                            BudgetRing(summary: summary, currencyCode: currencyCode)
                            BudgetLegend(slices: summary.slices, currencyCode: currencyCode)
                        }
                    }
                }
            }
        }
    }
}

private struct BudgetRing: View {
    let summary: BudgetSummary
    let currencyCode: String

    var body: some View {
        Chart(summary.slices) { slice in
            SectorMark(angle: .value(String(localized: "dashboard.chart.amount"), slice.amount.chartValue),
                       innerRadius: .ratio(0.66),
                       angularInset: 1.5)
                .cornerRadius(3)
                .foregroundStyle(slice.color)
                .accessibilityLabel(Text(verbatim: slice.displayName))
                .accessibilityValue(Text(verbatim: slice.amount.formattedAmount(currencyCode: currencyCode)))
        }
        .chartLegend(.hidden)
        .chartBackground { proxy in
            GeometryReader { geometry in
                if let plotFrame = proxy.plotFrame {
                    let frame = geometry[plotFrame]
                    VStack(spacing: 2) {
                        Text("dashboard.budget.total")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(verbatim: summary.total.formattedAmount(currencyCode: currencyCode))
                            .font(.subheadline.weight(.semibold))
                            .monospacedDigit()
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(width: frame.width * 0.56)
                    .position(x: frame.midX, y: frame.midY)
                }
            }
        }
        .frame(width: 160, height: 160)
    }
}

/// The ring's categories with their colours and amounts, largest first.
private struct BudgetLegend: View {
    let slices: [BudgetSlice]
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(slices) { slice in
                HStack(spacing: 8) {
                    Circle()
                        .fill(slice.color)
                        .frame(width: 10, height: 10)
                        .accessibilityHidden(true)
                    Text(verbatim: slice.displayName)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Text(verbatim: slice.amount.formattedAmount(currencyCode: currencyCode))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                .accessibilityElement(children: .combine)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private extension BudgetSlice {
    /// Tones of the accent colour and neighbouring hues, like the web's `generateAnalogColors`; "Other categories"
    /// is grey.
    private static let palette: [Color] = [.accentColor, .blue, .purple, .indigo, .teal, .pink, .orange]

    var color: Color {
        isOther ? Color(.systemGray3) : Self.palette[id % Self.palette.count]
    }

    var displayName: String {
        name ?? String(localized: "dashboard.budget.other")
    }
}

private extension BudgetSummary {
    /// A skeleton ring while the budget loads (`GEN-23`).
    static let placeholder = BudgetSummary([
        CategoryBudget(name: "Rent", amount: 1200),
        CategoryBudget(name: "Groceries", amount: 400),
        CategoryBudget(name: "Transport", amount: 150),
    ])
}
