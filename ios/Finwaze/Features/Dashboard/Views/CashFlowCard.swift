import Charts
import SwiftUI

/// "Monthly cash flow": incomes and expenses charged to accounts in the primary currency over the last 6 months,
/// side by side (`DASH-04`).
struct CashFlowCard: View {
    let state: CardState<[MonthlyCashFlow]>
    let currencyCode: String
    let onRetry: () -> Void

    var body: some View {
        ContentCard(
            title: "dashboard.cashFlow.title",
            subtitle: "dashboard.cashFlow.subtitle",
            systemImage: "chart.bar.fill"
        ) {
            CardStateView(state: state, placeholder: .placeholder, onRetry: onRetry) { months in
                CashFlowChart(months: months, currencyCode: currencyCode)
            }
        }
    }
}

private struct CashFlowChart: View {
    let months: [MonthlyCashFlow]
    let currencyCode: String
    /// A month touched on the chart: its bars stay bright and its figures show above it.
    @State private var selectedDate: Date?

    private var incomeName: String { String(localized: "dashboard.chart.income") }
    private var expenseName: String { String(localized: "dashboard.chart.expense") }
    private let incomeColor = Color.accentColor
    private let expenseColor = Color.accentColor.opacity(0.4)

    private var selectedMonth: MonthlyCashFlow? {
        guard let selectedDate else { return nil }
        return months.first { Calendar.current.isDate($0.month, equalTo: selectedDate, toGranularity: .month) }
    }

    var body: some View {
        // Looked up once per update: the chart redraws on every step of a drag across it.
        let selectedMonth = selectedMonth
        Chart {
            ForEach(months) { month in
                let isDimmed = selectedMonth.map { $0.id != month.id } ?? false
                bar(month, series: incomeName, amount: month.income, isDimmed: isDimmed)
                bar(month, series: expenseName, amount: month.expense, isDimmed: isDimmed)
            }
            if let selectedMonth {
                RuleMark(x: .value(String(localized: "dashboard.chart.month"), selectedMonth.month, unit: .month))
                    .foregroundStyle(.clear)
                    .annotation(position: .top, spacing: 4, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                        ChartCallout(
                            title: selectedMonth.month.formattedMonth(),
                            rows: [
                                .init(name: incomeName, amount: selectedMonth.income, color: incomeColor),
                                .init(name: expenseName, amount: selectedMonth.expense, color: expenseColor),
                            ],
                            currencyCode: currencyCode
                        )
                    }
            }
        }
        .chartForegroundStyleScale([incomeName: incomeColor, expenseName: expenseColor])
        .chartLegend(position: .top, alignment: .leading)
        .chartXSelection(value: $selectedDate)
        .chartXAxis {
            // Every month, by its initial: twelve short names do not fit a phone.
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated), centered: true)
            }
        }
        .currencyYAxis(currencyCode: currencyCode)
        .frame(height: 220)
        .sensoryFeedback(.selection, trigger: selectedMonth?.id)
    }

    private func bar(_ month: MonthlyCashFlow, series: String, amount: Decimal, isDimmed: Bool) -> some ChartContent {
        BarMark(
            x: .value(String(localized: "dashboard.chart.month"), month.month, unit: .month),
            y: .value(String(localized: "dashboard.chart.amount"), amount.chartValue)
        )
        .foregroundStyle(by: .value(String(localized: "dashboard.chart.series"), series))
        .position(by: .value(String(localized: "dashboard.chart.series"), series))
        .cornerRadius(5)
        .opacity(isDimmed ? 0.35 : 1)
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
