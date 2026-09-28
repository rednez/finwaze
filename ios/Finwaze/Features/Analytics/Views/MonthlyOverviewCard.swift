import Charts
import SwiftUI

/// "Monthly overview" (`ANL-03`): the balance, incomes or expenses of every day of the month against the month
/// before, laid over each other by the day's number so months of different lengths line up, like the web.
struct MonthlyOverviewCard: View {
    @Bindable var viewModel: AnalyticsViewModel
    let currencyCode: String

    var body: some View {
        ContentCard(title: "analytics.overview.title") {
            VStack(alignment: .leading, spacing: 12) {
                Picker("analytics.overview.metric", selection: $viewModel.overviewMetric) {
                    Text("analytics.overview.balance").tag(AnalyticsViewModel.OverviewMetric.balance)
                    Text("dashboard.chart.income").tag(AnalyticsViewModel.OverviewMetric.income)
                    Text("dashboard.chart.expense").tag(AnalyticsViewModel.OverviewMetric.expense)
                }
                .pickerStyle(.segmented)
                CardStateView(
                    state: viewModel.overview.state,
                    placeholder: .placeholder,
                    onRetry: { Task { await viewModel.overview.refresh() } }
                ) { overview in
                    MonthlyOverviewChart(
                        overview: overview,
                        metric: viewModel.overviewMetric,
                        month: viewModel.filter.month,
                        currencyCode: currencyCode
                    )
                }
            }
        }
    }
}

private struct MonthlyOverviewChart: View {
    let overview: MonthlyOverview
    let metric: AnalyticsViewModel.OverviewMetric
    let month: YearMonth
    let currencyCode: String
    @State private var selectedDay: Int?

    private var currentName: String { month.title }
    private var previousName: String { month.adding(months: -1).title }
    private var seriesTitle: String { String(localized: "dashboard.chart.series") }
    private var dayTitle: String { String(localized: "wallet.chart.day") }
    private var amountTitle: String { String(localized: "dashboard.chart.amount") }

    private var lastDay: Int {
        max(overview.current.last?.dayOfMonth ?? 1, overview.previous.last?.dayOfMonth ?? 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            legend
            Chart {
                ForEach(overview.current) { point in
                    AreaMark(x: .value(dayTitle, point.dayOfMonth), y: .value(amountTitle, value(of: point).chartValue))
                        .foregroundStyle(
                            .linearGradient(
                                colors: [Color.accentColor.opacity(0.3), Color.accentColor.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.monotone)
                        .accessibilityHidden(true)
                    line(point, series: currentName)
                        .accessibilityLabel(Text("analytics.overview.day \(point.dayOfMonth)"))
                        .accessibilityValue(Text(verbatim: spokenValue(day: point.dayOfMonth)))
                }
                ForEach(overview.previous) { point in
                    // Told apart by the dash, not only by colour.
                    line(point, series: previousName, dash: [5, 3])
                        .accessibilityLabel(Text("analytics.overview.day \(point.dayOfMonth)"))
                        .accessibilityValue(Text(verbatim: spokenValue(day: point.dayOfMonth)))
                        // A day the month also has is read out with it.
                        .accessibilityHidden(point.dayOfMonth <= (overview.current.last?.dayOfMonth ?? 0))
                }
                if let selectedDay {
                    RuleMark(x: .value(dayTitle, selectedDay))
                        .foregroundStyle(.secondary.opacity(0.5))
                        .annotation(position: .top, spacing: 4, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            SelectedDayCallout(lines: lines(day: selectedDay), day: selectedDay)
                        }
                }
            }
            .chartForegroundStyleScale(domain: [currentName, previousName], range: [Color.accentColor, Color.secondary])
            .chartLegend(.hidden)
            .chartXSelection(value: $selectedDay)
            .chartXScale(domain: 1...lastDay)
            .chartXAxis {
                AxisMarks(values: [1, 5, 10, 15, 20, 25, 30].filter { $0 <= lastDay }) { _ in
                    AxisGridLine()
                    AxisValueLabel()
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
    }

    /// The months by name, with their line's style: solid for this one, dashed for the one before.
    private var legend: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 16) { legendItems }
            VStack(alignment: .leading, spacing: 4) { legendItems }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var legendItems: some View {
        LegendLine(color: .accentColor, dash: [], name: currentName)
        LegendLine(color: .secondary, dash: [5, 3], name: previousName)
    }

    private func line(_ point: DailyOverviewPoint, series: String, dash: [CGFloat] = []) -> some ChartContent {
        LineMark(
            x: .value(dayTitle, point.dayOfMonth),
            y: .value(amountTitle, value(of: point).chartValue),
            series: .value(seriesTitle, series)
        )
        .foregroundStyle(by: .value(seriesTitle, series))
        // Smooth like the web, but never overshooting.
        .interpolationMethod(.monotone)
        .lineStyle(StrokeStyle(lineWidth: 2, dash: dash))
    }

    private func value(of point: DailyOverviewPoint) -> Decimal {
        switch metric {
        case .balance: point.balance
        case .income: point.income
        case .expense: point.expense
        }
    }

    /// "September 2026: $1,200.00" for each month that has the day.
    private func lines(day: Int) -> [String] {
        [(currentName, overview.current), (previousName, overview.previous)].compactMap { name, points in
            points.first { $0.dayOfMonth == day }.map { point in
                String(localized: "analytics.overview.value \(name) \(value(of: point).formattedAmount(currencyCode: currencyCode))")
            }
        }
    }

    private func spokenValue(day: Int) -> String {
        lines(day: day).joined(separator: ", ")
    }
}

/// A line of the legend: a short stroke in the series' style and its name.
private struct LegendLine: View {
    let color: Color
    let dash: [CGFloat]
    let name: String

    var body: some View {
        HStack(spacing: 6) {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 1))
                path.addLine(to: CGPoint(x: 18, y: 1))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2, dash: dash))
            .frame(width: 18, height: 2)
            Text(verbatim: name)
        }
    }
}

/// The picked day's figures above the chart, like the web's tooltip.
private struct SelectedDayCallout: View {
    let lines: [String]
    let day: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("analytics.overview.day \(day)")
                .font(.caption.weight(.semibold))
            ForEach(lines, id: \.self) { line in
                Text(verbatim: line)
            }
        }
        .font(.caption)
        .monospacedDigit()
        .padding(8)
        .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 8))
    }
}

private extension MonthlyOverview {
    /// A skeleton chart while the months load (`GEN-23`).
    static let placeholder = MonthlyOverview(current: points(from: 1000), previous: points(from: 1200))

    private static func points(from start: Decimal) -> [DailyOverviewPoint] {
        (1...30).map { day in
            DailyOverviewPoint(
                day: .now,
                dayOfMonth: day,
                income: day % 7 == 1 ? 300 : 0,
                expense: Decimal(40 + day % 5 * 20),
                balance: start + Decimal(day * 15)
            )
        }
    }
}
