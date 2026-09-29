import Charts
import SwiftUI

/// "Savings overview": net deposits into the goals in one of their currencies, month by month, for the filter's
/// year against the year before (`GOAL-16`). Withdrawals count against deposits, so a month may dip below zero.
struct SavingsOverviewCard: View {
    let state: CardState<[MonthlySavings]>
    let year: Int
    let currencyCodes: [String]
    let currencyCode: String
    let onSelectCurrency: @MainActor @Sendable (String) -> Void
    let onRetry: () -> Void

    var body: some View {
        ContentCard(title: "goals.overview.title", subtitle: "goals.overview.subtitle") {
            VStack(alignment: .leading, spacing: 12) {
                if currencyCodes.count > 1 {
                    CurrencyFilterMenu(
                        title: "goals.overview.currency",
                        currencyCodes: currencyCodes,
                        selection: currencyCode,
                        onSelect: onSelectCurrency
                    )
                }
                CardStateView(state: state, placeholder: .placeholder(year: year), onRetry: onRetry) { months in
                    SavingsOverviewChart(months: months, year: year, currencyCode: currencyCode)
                }
            }
        }
    }
}

private struct SavingsOverviewChart: View {
    let months: [MonthlySavings]
    let year: Int
    let currencyCode: String

    private var currentName: String { String(year) }
    private var previousName: String { String(year - 1) }

    var body: some View {
        Chart {
            ForEach(months) { month in
                if let start = month.month.start(in: .current) {
                    bar(start, series: currentName, amount: month.currentYear)
                    bar(start, series: previousName, amount: month.previousYear)
                }
            }
            RuleMark(y: .value(String(localized: "dashboard.chart.amount"), 0))
                .foregroundStyle(.secondary)
                .lineStyle(StrokeStyle(lineWidth: 1))
        }
        .chartForegroundStyleScale([currentName: Color.accentColor, previousName: Color.accentColor.opacity(0.4)])
        .chartLegend(position: .top, alignment: .leading)
        .chartXAxis {
            // Every month, by its initial: twelve short names do not fit a phone.
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
            }
        }
        .currencyYAxis(currencyCode: currencyCode)
        .frame(height: 220)
    }

    private func bar(_ month: Date, series: String, amount: Decimal) -> some ChartContent {
        BarMark(
            x: .value(String(localized: "dashboard.chart.month"), month, unit: .month),
            y: .value(String(localized: "dashboard.chart.amount"), amount.chartValue)
        )
        .foregroundStyle(by: .value(String(localized: "dashboard.chart.series"), series))
        .position(by: .value(String(localized: "dashboard.chart.series"), series))
        .cornerRadius(3)
        .accessibilityLabel(Text(verbatim: "\(month.formatted(.dateTime.month(.wide))) \(series)"))
        .accessibilityValue(Text(verbatim: amount.formattedAmount(currencyCode: currencyCode)))
    }
}

private extension [MonthlySavings] {
    /// Skeleton bars while the chart loads (`GEN-23`).
    static func placeholder(year: Int) -> [MonthlySavings] {
        (1...12).map { month in
            MonthlySavings(
                month: YearMonth(year: year, month: month),
                currentYear: Decimal(200 + month * 30),
                previousYear: Decimal(150 + month * 25)
            )
        }
    }
}
