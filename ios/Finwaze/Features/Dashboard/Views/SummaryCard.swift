import SwiftUI

/// One of the three summary cards (`DASH-02`).
enum SummaryKind: CaseIterable {
    case balance, income, expenses

    var title: LocalizedStringKey {
        switch self {
        case .balance: "dashboard.totalBalance"
        case .income: "dashboard.income"
        case .expenses: "dashboard.expenses"
        }
    }

    /// Growth is good for the balance and income, bad for expenses (`DASH-03`).
    var growthIsGood: Bool {
        self != .expenses
    }

    func current(in totals: DashboardTotals) -> Decimal {
        switch self {
        case .balance: totals.totalBalance
        case .income: totals.monthlyIncome
        case .expenses: totals.monthlyExpense
        }
    }

    func previous(in totals: DashboardTotals) -> Decimal {
        switch self {
        case .balance: totals.previousTotalBalance
        case .income: totals.previousMonthlyIncome
        case .expenses: totals.previousMonthlyExpense
        }
    }
}

/// A summary figure in the primary currency with its change against last month (`DASH-02`, `DASH-03`, `GEN-06`).
struct SummaryCard: View {
    let kind: SummaryKind
    let state: CardState<DashboardTotals>
    let currencyCode: String
    let onRetry: () -> Void

    var body: some View {
        DashboardCard(title: kind.title) {
            CardStateView(state: state, placeholder: .placeholder, onRetry: onRetry) { totals in
                let current = kind.current(in: totals)
                let trend = TrendChange(
                    current: current,
                    previous: kind.previous(in: totals),
                    growthIsGood: kind.growthIsGood
                )
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: current.formattedAmount(currencyCode: currencyCode))
                        .font(.title2.weight(.semibold))
                        .monospacedDigit()
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    TrendBadge(trend: trend)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

/// "↑ 12.5 % vs last month", green when the change is good and red when bad (`DASH-03`). The arrow and the spoken
/// label carry the direction, not only the colour.
struct TrendBadge: View {
    let trend: TrendChange

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 6) {
                badge
                caption
            }
            VStack(alignment: .leading, spacing: 4) {
                badge
                caption
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var badge: some View {
        HStack(spacing: 2) {
            if let arrow {
                Image(systemName: arrow)
                    .font(.caption.weight(.bold))
            }
            Text(verbatim: trend.formattedRatio())
                .monospacedDigit()
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .background(color.opacity(0.15), in: .capsule)
    }

    private var caption: some View {
        Text("dashboard.vsLastMonth")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .lineLimit(1)
    }

    private var arrow: String? {
        switch trend.direction {
        case .up: "arrow.up"
        case .down: "arrow.down"
        case .flat: nil
        }
    }

    private var color: Color {
        switch trend.assessment {
        case .good: .green
        case .bad: .red
        case .neutral: .secondary
        }
    }

    private var accessibilityText: Text {
        let ratio = trend.formattedRatio()
        return switch trend.direction {
        case .up: Text("dashboard.trend.up \(ratio)")
        case .down: Text("dashboard.trend.down \(ratio)")
        case .flat: Text("dashboard.trend.flat")
        }
    }
}

private extension DashboardTotals {
    /// Skeleton figures while the totals load (`GEN-23`).
    static let placeholder = DashboardTotals(
        totalBalance: 12345.67,
        monthlyIncome: 3200,
        monthlyExpense: 1573,
        previousTotalBalance: 11000,
        previousMonthlyIncome: 3000,
        previousMonthlyExpense: 1600
    )
}
