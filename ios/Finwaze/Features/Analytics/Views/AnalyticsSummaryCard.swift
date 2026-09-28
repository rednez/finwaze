import SwiftUI

/// A summary card of Analytics (`ANL-02`): the month's figure with its change against last month, like the
/// Dashboard's, the difference in words and how many transactions and groups are behind it.
struct AnalyticsSummaryCard: View {
    let kind: SummaryKind
    let state: CardState<AnalyticsSummary>
    let currencyCode: String
    let onRetry: () -> Void

    var body: some View {
        ContentCard(title: kind.title) {
            CardStateView(state: state, placeholder: .placeholder, onRetry: onRetry) { summary in
                VStack(alignment: .leading, spacing: 12) {
                    SummaryFigure(
                        kind: kind,
                        current: kind.current(in: summary),
                        previous: kind.previous(in: summary),
                        currencyCode: currencyCode
                    )
                    comparison(SummaryComparison(current: kind.current(in: summary), previous: kind.previous(in: summary)))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    counts(summary)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func comparison(_ comparison: SummaryComparison) -> Text {
        let difference = comparison.difference.formattedAmount(currencyCode: currencyCode)
        return switch comparison.direction {
        case .more: Text("analytics.summary.more \(difference)")
        case .less: Text("analytics.summary.less \(difference)")
        case .same: Text("analytics.summary.same")
        }
    }

    private func counts(_ summary: AnalyticsSummary) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 16) {
                countLabels(summary)
            }
            VStack(alignment: .leading, spacing: 4) {
                countLabels(summary)
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }

    @ViewBuilder
    private func countLabels(_ summary: AnalyticsSummary) -> some View {
        Label("analytics.summary.transactions \(kind.transactionCount(in: summary))", systemImage: "arrow.left.arrow.right")
        Label("analytics.summary.groups \(kind.groupsCount(in: summary))", systemImage: "folder")
    }
}

private extension AnalyticsSummary {
    /// Skeleton figures while the summary loads (`GEN-23`).
    static let placeholder = AnalyticsSummary(
        monthlyIncome: 3200,
        previousMonthlyIncome: 3000,
        monthlyExpense: 1573,
        previousMonthlyExpense: 1600,
        totalBalance: 12345.67,
        previousTotalBalance: 11000,
        incomeTransactionCount: 2,
        expenseTransactionCount: 24,
        incomeGroupsCount: 1,
        expenseGroupsCount: 6
    )
}
