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
        ContentCard(
            title: "goals.overview.title",
            detail: Text.summary(String(year), currencyCode),
            systemImage: "chart.bar.fill",
            tint: .green
        ) {
            if currencyCodes.count > 1 {
                ChartSettingsMenu(currencyCodes: currencyCodes, currencyCode: currencyCode, onSelectCurrency: onSelectCurrency)
            }
        } content: {
            CardStateView(state: state, placeholder: .placeholder(year: year), onRetry: onRetry) { months in
                SavingsOverviewChart(months: months, year: year, currencyCode: currencyCode)
            }
            .accessibilityHint(Text("goals.overview.subtitle"))
        }
    }
}

private struct SavingsOverviewChart: View {
    let months: [MonthlySavings]
    let year: Int
    let currencyCode: String
    /// A month touched on the chart: its bars stay bright and both years' figures show above it.
    @State private var selectedDate: Date?

    private var currentName: String { String(year) }
    private var previousName: String { String(year - 1) }
    private let currentColor = Color.accentColor
    private let previousColor = Color.accentColor.opacity(0.4)

    private var selectedMonth: MonthlySavings? {
        guard let selectedDate else { return nil }
        let selected = YearMonth(selectedDate, in: .current)
        return months.first { $0.month == selected }
    }

    var body: some View {
        // Looked up once per update: the chart redraws on every step of a drag across it.
        let selectedMonth = selectedMonth
        Chart {
            ForEach(months) { month in
                if let start = month.month.start(in: .current) {
                    let isDimmed = selectedMonth.map { $0.id != month.id } ?? false
                    bar(start, series: currentName, amount: month.currentYear, isDimmed: isDimmed)
                    bar(start, series: previousName, amount: month.previousYear, isDimmed: isDimmed)
                }
            }
            RuleMark(y: .value(String(localized: "dashboard.chart.amount"), 0))
                .foregroundStyle(.secondary)
                .lineStyle(StrokeStyle(lineWidth: 1))
            if let selectedMonth, let start = selectedMonth.month.start(in: .current) {
                RuleMark(x: .value(String(localized: "dashboard.chart.month"), start, unit: .month))
                    .foregroundStyle(.clear)
                    .annotation(position: .top, spacing: 4, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                        ChartCallout(
                            title: start.formatted(.dateTime.month(.wide)),
                            rows: [
                                .init(name: currentName, amount: selectedMonth.currentYear, color: currentColor),
                                .init(name: previousName, amount: selectedMonth.previousYear, color: previousColor),
                            ],
                            currencyCode: currencyCode
                        )
                    }
            }
        }
        .chartForegroundStyleScale([currentName: currentColor, previousName: previousColor])
        .chartLegend(position: .top, alignment: .leading)
        .chartXSelection(value: $selectedDate)
        .chartXAxis {
            // Every month, by its initial: twelve short names do not fit a phone.
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
            }
        }
        .currencyYAxis(currencyCode: currencyCode)
        .frame(height: 220)
        .sensoryFeedback(.selection, trigger: selectedMonth?.id)
    }

    private func bar(_ month: Date, series: String, amount: Decimal, isDimmed: Bool) -> some ChartContent {
        BarMark(
            x: .value(String(localized: "dashboard.chart.month"), month, unit: .month),
            y: .value(String(localized: "dashboard.chart.amount"), amount.chartValue)
        )
        .foregroundStyle(by: .value(String(localized: "dashboard.chart.series"), series))
        .position(by: .value(String(localized: "dashboard.chart.series"), series))
        .cornerRadius(4)
        .opacity(isDimmed ? 0.35 : 1)
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
