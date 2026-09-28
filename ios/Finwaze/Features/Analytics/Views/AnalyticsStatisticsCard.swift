import SwiftUI

/// "Statistics" (`ANL-05`): the month's expenses, incomes or budget by group, as a ring with each group's share and
/// amount. Expenses and incomes count the selected accounts; the budget has no accounts.
struct AnalyticsStatisticsCard: View {
    @Bindable var viewModel: AnalyticsViewModel
    let currencyCode: String

    var body: some View {
        ContentCard(title: "analytics.statistics.title") {
            VStack(alignment: .leading, spacing: 12) {
                Picker("analytics.statistics.mode", selection: $viewModel.statisticsMode) {
                    Text("dashboard.chart.expense").tag(AnalyticsViewModel.StatisticsMode.expense)
                    Text("dashboard.chart.income").tag(AnalyticsViewModel.StatisticsMode.income)
                    Text("analytics.statistics.budget").tag(AnalyticsViewModel.StatisticsMode.budget)
                }
                .pickerStyle(.segmented)
                CardStateView(
                    state: viewModel.statistics.state,
                    placeholder: .placeholder,
                    onRetry: { Task { await viewModel.statistics.refresh() } }
                ) { statistics in
                    let summary = viewModel.statisticsSummary(of: statistics)
                    if summary.slices.isEmpty {
                        Text(emptyMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        DonutChart(summary: summary, currencyCode: currencyCode, caption: caption, showsShare: true)
                    }
                }
            }
        }
    }

    /// "Expenses for September 2026" in the middle of the ring.
    private var caption: LocalizedStringKey {
        let month = viewModel.filter.month.start(in: .current)?.formattedMonth() ?? ""
        return switch viewModel.statisticsMode {
        case .expense: "analytics.statistics.expensesFor \(month)"
        case .income: "analytics.statistics.incomeFor \(month)"
        case .budget: "analytics.statistics.budgetFor \(month)"
        }
    }

    private var emptyMessage: LocalizedStringKey {
        switch viewModel.statisticsMode {
        case .expense: "wallet.statistics.empty.expense"
        case .income: "wallet.statistics.empty.income"
        case .budget: "analytics.statistics.empty.budget"
        }
    }
}

private extension GroupStatistics {
    /// A skeleton ring while the month loads (`GEN-23`).
    static let placeholder = GroupStatistics(
        amounts: [
            GroupAmounts(id: -1, name: "Housing", income: 0, expense: 1200),
            GroupAmounts(id: -2, name: "Food", income: 0, expense: 400),
            GroupAmounts(id: -3, name: "Transport", income: 0, expense: 150),
        ],
        budgets: []
    )
}
