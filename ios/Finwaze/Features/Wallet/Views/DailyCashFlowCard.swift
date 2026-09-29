import Charts
import SwiftUI

/// "Daily cash flow": incomes and expenses in a purchase currency for every day of the month, as two lines; incomes
/// can be switched off to see expenses only (`ACC-03`).
struct DailyCashFlowCard: View {
    @Bindable var viewModel: DailyCashFlowViewModel
    let dataVersion: Int

    private var widget: WalletWidgetViewModel<[DailyCashFlow]> { viewModel.widget }

    var body: some View {
        ContentCard(title: "wallet.dailyFlow.title", subtitle: "wallet.dailyFlow.subtitle") {
            if let currencyCode = widget.currencyCode {
                VStack(alignment: .leading, spacing: 12) {
                    WalletWidgetFilterBar(widget: widget, currencyCode: currencyCode)
                    Toggle("wallet.dailyFlow.incomes", isOn: $viewModel.includesIncome)
                        .font(.subheadline)
                    CardStateView(
                        state: widget.state,
                        placeholder: .placeholder(widget.filter.month),
                        onRetry: { Task { await widget.refresh() } }
                    ) { days in
                        DailyCashFlowChart(days: days, includesIncome: viewModel.includesIncome, currencyCode: currencyCode)
                        if viewModel.isEmpty(days) {
                            Text("wallet.dailyFlow.empty")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .loads(widget, dataVersion: dataVersion)
    }
}

private struct DailyCashFlowChart: View {
    let days: [DailyCashFlow]
    let includesIncome: Bool
    let currencyCode: String
    @State private var selectedDate: Date?

    // Looked up once, not per mark: the chart renders on every frame while a day is picked.
    private let incomeName = String(localized: "dashboard.chart.income")
    private let expenseName = String(localized: "dashboard.chart.expense")
    private let seriesTitle = String(localized: "dashboard.chart.series")
    private let dayTitle = String(localized: "wallet.chart.day")
    private let amountTitle = String(localized: "dashboard.chart.amount")

    private var selectedDay: DailyCashFlow? {
        guard let selectedDate else { return nil }
        return days.first { Calendar.current.isDate($0.day, inSameDayAs: selectedDate) }
    }

    var body: some View {
        Chart {
            ForEach(days) { day in
                if includesIncome {
                    line(day, series: incomeName, amount: day.income)
                }
                // Told apart by the dash too, not only by colour.
                line(day, series: expenseName, amount: day.expense, dash: [5, 3])
            }
            if let selectedDay {
                RuleMark(x: .value(dayTitle, selectedDay.day, unit: .day))
                    .foregroundStyle(.secondary.opacity(0.5))
                    .annotation(position: .top, spacing: 4, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                        SelectedDayCallout(day: selectedDay, includesIncome: includesIncome, currencyCode: currencyCode)
                    }
            }
        }
        .chartForegroundStyleScale(
            domain: includesIncome ? [incomeName, expenseName] : [expenseName],
            range: includesIncome ? [Color.accentColor, Color.orange] : [Color.orange]
        )
        .chartLegend(position: .top, alignment: .leading)
        .chartXSelection(value: $selectedDate)
        .chartXAxis {
            // Every fifth day: a month of day numbers does not fit a phone.
            AxisMarks(values: .stride(by: .day, count: 5)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day())
            }
        }
        .currencyYAxis(currencyCode: currencyCode)
        .frame(height: 220)
    }

    private func line(_ day: DailyCashFlow, series: String, amount: Decimal, dash: [CGFloat] = []) -> some ChartContent {
        LineMark(
            x: .value(dayTitle, day.day, unit: .day),
            y: .value(amountTitle, amount.chartValue),
            series: .value(seriesTitle, series)
        )
        .foregroundStyle(by: .value(seriesTitle, series))
        // Smooth like the web, but never overshooting: a spike must not dip below zero next to it.
        .interpolationMethod(.monotone)
        .lineStyle(StrokeStyle(lineWidth: 2, dash: dash))
        .accessibilityLabel(Text(verbatim: "\(day.day.formatted(.dateTime.day().month())), \(series)"))
        .accessibilityValue(Text(verbatim: amount.formattedAmount(currencyCode: currencyCode)))
    }
}

/// The picked day's figures above the chart, like the web's tooltip.
private struct SelectedDayCallout: View {
    let day: DailyCashFlow
    let includesIncome: Bool
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: day.day.formatted(.dateTime.day().month()))
                .font(.caption.weight(.semibold))
            if includesIncome {
                Text("wallet.dailyFlow.income \(day.income.formattedAmount(currencyCode: currencyCode))")
            }
            Text("wallet.dailyFlow.expense \(day.expense.formattedAmount(currencyCode: currencyCode))")
        }
        .font(.caption)
        .monospacedDigit()
        .padding(8)
        .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 8))
    }
}

private extension [DailyCashFlow] {
    /// A skeleton chart while the month loads (`GEN-23`).
    static func placeholder(_ month: YearMonth) -> [DailyCashFlow] {
        let calendar = Calendar.current
        guard let start = month.start(in: calendar) else { return [] }
        return (0..<30).compactMap { index in
            calendar.date(byAdding: .day, value: index, to: start).map {
                DailyCashFlow(day: $0, income: Decimal(index % 7 == 0 ? 300 : 0), expense: Decimal(40 + index % 5 * 20))
            }
        }
    }
}
