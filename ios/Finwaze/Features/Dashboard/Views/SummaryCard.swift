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

    /// The card's icon, the same arrows as the month's totals in Transactions.
    var systemImage: String {
        switch self {
        case .balance: "wallet.bifold.fill"
        case .income: "arrow.down.left"
        case .expenses: "arrow.up.right"
        }
    }

    var tint: Color {
        switch self {
        case .balance: .accentColor
        case .income: .green
        case .expenses: .orange
        }
    }

    /// The balance is the screen's headline; income and expenses sit side by side under it.
    var amountSize: AmountText.Size {
        self == .balance ? .hero : .medium
    }

    var cardStyle: ContentCardStyle {
        self == .balance ? .prominent : .plain
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
        ContentCard(title: kind.title, systemImage: kind.systemImage, tint: kind.tint, style: kind.cardStyle) {
            CardStateView(state: state, placeholder: .placeholder, onRetry: onRetry) { totals in
                SummaryFigure(
                    kind: kind,
                    current: kind.current(in: totals),
                    previous: kind.previous(in: totals),
                    currencyCode: currencyCode
                )
                .accessibilityElement(children: .combine)
            }
        }
    }
}

/// A summary card's figure with its change against last month (`DASH-02`, `DASH-03`, `ANL-02`): shared by the
/// Dashboard and Analytics.
struct SummaryFigure: View {
    let kind: SummaryKind
    let current: Decimal
    let previous: Decimal
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AmountText(amount: current, currencyCode: currencyCode, size: kind.amountSize)
            TrendBadge(trend: TrendChange(current: current, previous: previous, growthIsGood: kind.growthIsGood))
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
