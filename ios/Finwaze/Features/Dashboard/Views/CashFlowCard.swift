import Charts
import SwiftUI

/// "Monthly cash flow": incomes and expenses charged to accounts in the primary currency over the last 12 months,
/// side by side (`DASH-04`).
struct CashFlowCard: View {
    let state: CardState<[MonthlyCashFlow]>
    let currencyCode: String
    let onRetry: () -> Void

    var body: some View {
        ContentCard(title: "dashboard.cashFlow.title", subtitle: "dashboard.cashFlow.subtitle") {
            CardStateView(state: state, placeholder: .placeholder, onRetry: onRetry) { months in
                CashFlowChart(months: months, currencyCode: currencyCode)
            }
        }
    }
}

private struct CashFlowChart: View {
    let months: [MonthlyCashFlow]
    let currencyCode: String

    private var incomeName: String { String(localized: "dashboard.chart.income") }
    private var expenseName: String { String(localized: "dashboard.chart.expense") }

    var body: some View {
        Chart(months) { month in
            bar(month, series: incomeName, amount: month.income)
            bar(month, series: expenseName, amount: month.expense)
        }
        .chartForegroundStyleScale([incomeName: Color.accentColor, expenseName: Color.accentColor.opacity(0.4)])
        .chartLegend(position: .top, alignment: .leading)
        .chartXAxis {
            // Every month, by its initial: twelve short names do not fit a phone.
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(verbatim: Decimal(amount).formatted(.currency(code: currencyCode).notation(.compactName)))
                    }
                }
            }
        }
        .frame(height: 220)
    }

    private func bar(_ month: MonthlyCashFlow, series: String, amount: Decimal) -> some ChartContent {
        BarMark(
            x: .value(String(localized: "dashboard.chart.month"), month.month, unit: .month),
            y: .value(String(localized: "dashboard.chart.amount"), amount.chartValue)
        )
        .foregroundStyle(by: .value(String(localized: "dashboard.chart.series"), series))
        .position(by: .value(String(localized: "dashboard.chart.series"), series))
        .cornerRadius(3)
        .accessibilityLabel(Text(verbatim: "\(month.month.formattedMonth()), \(series)"))
        .accessibilityValue(Text(verbatim: amount.formattedAmount(currencyCode: currencyCode)))
    }
}

private extension [MonthlyCashFlow] {
    /// Skeleton bars while the chart loads (`GEN-23`).
    static var placeholder: [MonthlyCashFlow] {
        DashboardMapper.lastMonths(DashboardViewModel.cashFlowMonths).enumerated().compactMap { index, month in
            month.start(in: .current).map {
                MonthlyCashFlow(month: $0, income: 3000, expense: Decimal(1500 + index % 4 * 300))
            }
        }
    }
}
