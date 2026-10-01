import SwiftUI

/// "Statistics": the month's expenses or incomes in a purchase currency by group, as a ring with the total in the
/// middle and each group's share (`ACC-05`).
struct WalletStatisticsCard: View {
    @Bindable var viewModel: WalletStatisticsViewModel
    let dataVersion: Int

    private var widget: WalletWidgetViewModel<[GroupAmounts]> { viewModel.widget }

    var body: some View {
        ContentCard(
            title: "wallet.statistics.title",
            detail: widget.currencyCode.map { Text.summary(widget.filter.month.title, $0) },
            systemImage: "chart.pie.fill",
            tint: .purple
        ) {
            if let currencyCode = widget.currencyCode {
                ChartSettingsMenu(
                    periodTitle: widget.filter.month.title,
                    onShift: widget.shiftMonth(by:),
                    currencyCodes: widget.currencyCodes,
                    currencyCode: currencyCode,
                    onSelectCurrency: widget.selectCurrency
                )
            }
        } content: {
            if let currencyCode = widget.currencyCode {
                VStack(alignment: .leading, spacing: 14) {
                    Picker("wallet.statistics.kind", selection: $viewModel.kind) {
                        Text("dashboard.chart.expense").tag(WalletStatisticsViewModel.Kind.expense)
                        Text("dashboard.chart.income").tag(WalletStatisticsViewModel.Kind.income)
                    }
                    .pickerStyle(.segmented)
                    CardStateView(
                        state: widget.state,
                        placeholder: .placeholder,
                        onRetry: { Task { await widget.refresh() } }
                    ) { groups in
                        let summary = viewModel.summary(of: groups)
                        if summary.slices.isEmpty {
                            Text(viewModel.kind == .expense ? "wallet.statistics.empty.expense" : "wallet.statistics.empty.income")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            DonutChart(
                                summary: summary,
                                currencyCode: currencyCode,
                                caption: viewModel.kind == .expense
                                    ? "wallet.statistics.totalExpenses" : "wallet.statistics.totalIncome",
                                showsShare: true
                            )
                        }
                    }
                }
            }
        }
        .loads(widget, dataVersion: dataVersion)
    }
}

private extension [GroupAmounts] {
    /// A skeleton ring while the month loads (`GEN-23`).
    static let placeholder = [
        GroupAmounts(id: -1, name: "Housing", income: 0, expense: 1200),
        GroupAmounts(id: -2, name: "Food", income: 0, expense: 400),
        GroupAmounts(id: -3, name: "Transport", income: 0, expense: 150),
    ]
}
