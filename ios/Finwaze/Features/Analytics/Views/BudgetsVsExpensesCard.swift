import Charts
import SwiftUI

/// "Budgets vs Expenses" (`ANL-04`): the plan against the expenses of every month of the year, by the year's own
/// stepper; the month and the accounts do not apply. Expenses are the amounts charged to accounts in the currency,
/// which may differ from Budget's purchase-currency spending (`Q-03`) — the note under the chart says so.
struct BudgetsVsExpensesCard: View {
    let viewModel: AnalyticsViewModel
    let currencyCode: String

    var body: some View {
        let year = viewModel.filter.budgetYear.formatted(.number.grouping(.never))
        ContentCard(
            title: "analytics.budgets.title",
            detail: Text.summary(year, currencyCode),
            systemImage: "chart.bar.xaxis",
            tint: .orange
        ) {
            ChartSettingsMenu(
                periodTitle: year,
                previousTitle: "analytics.previousYear",
                nextTitle: "analytics.nextYear",
                onShift: viewModel.shiftBudgetYear(by:)
            )
        } content: {
            VStack(alignment: .leading, spacing: 10) {
                CardStateView(
                    state: viewModel.budgetsVsExpenses.state,
                    placeholder: .placeholder(year: viewModel.filter.budgetYear),
                    onRetry: { Task { await viewModel.budgetsVsExpenses.refresh() } }
                ) { months in
                    BudgetsVsExpensesChart(months: months, currencyCode: currencyCode)
                    if months.allSatisfy({ $0.budget == 0 && $0.expense == 0 }) {
                        Text("analytics.budgets.empty")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                // Which expenses count here, as they may differ from Budget's (`Q-03`).
                Text("analytics.budgets.subtitle \(currencyCode)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct BudgetsVsExpensesChart: View {
    let months: [MonthlyBudgetExpense]
    let currencyCode: String
    @State private var selectedDate: Date?
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var budgetName: String { String(localized: "analytics.budgets.budgets") }
    private var expensesName: String { String(localized: "analytics.budgets.expenses") }
    private var seriesTitle: String { String(localized: "dashboard.chart.series") }
    private var monthTitle: String { String(localized: "dashboard.chart.month") }
    private var amountTitle: String { String(localized: "dashboard.chart.amount") }

    /// The height of the solid line that tops a budget bar, so it reads apart from expenses by its shape too.
    private var capHeight: Double {
        let largest = months.map { max($0.budget, $0.expense) }.max() ?? 0
        return max(largest.chartValue * 0.015, 0)
    }

    private var selectedMonth: MonthlyBudgetExpense? {
        guard let selectedDate else { return nil }
        let picked = YearMonth(selectedDate, in: .current)
        return months.first { $0.month == picked }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            legend
            Chart {
                ForEach(months) { month in
                    budgetBars(month)
                    BarMark(x: .value(monthTitle, month.start, unit: .month), y: .value(amountTitle, month.expense.chartValue))
                        .position(by: .value(seriesTitle, expensesName))
                        .foregroundStyle(Color.accentColor)
                        .cornerRadius(2)
                        .accessibilityLabel(Text(verbatim: month.start.formattedMonth()))
                        .accessibilityValue(Text(verbatim: spokenValue(month)))
                }
                if let selectedMonth {
                    RuleMark(x: .value(monthTitle, selectedMonth.start, unit: .month))
                        .foregroundStyle(.secondary.opacity(0.3))
                        .annotation(position: .top, spacing: 4, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            SelectedMonthCallout(month: selectedMonth, currencyCode: currencyCode)
                        }
                }
            }
            .chartXSelection(value: $selectedDate)
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { _ in
                    // By the initial in portrait, where twelve short names do not fit; short names in landscape.
                    AxisValueLabel(
                        format: .dateTime.month(verticalSizeClass == .compact ? .abbreviated : .narrow),
                        centered: true
                    )
                }
            }
            .currencyYAxis(currencyCode: currencyCode)
            .frame(height: 220)
        }
    }

    /// A light bar topped with a solid line: the plan, beside the solid bar of expenses.
    @ChartContentBuilder
    private func budgetBars(_ month: MonthlyBudgetExpense) -> some ChartContent {
        BarMark(x: .value(monthTitle, month.start, unit: .month), y: .value(amountTitle, month.budget.chartValue))
            .position(by: .value(seriesTitle, budgetName))
            .foregroundStyle(Color.accentColor.opacity(0.25))
            .accessibilityHidden(true)
        if month.budget > 0 {
            BarMark(
                x: .value(monthTitle, month.start, unit: .month),
                yStart: .value(amountTitle, max(month.budget.chartValue - capHeight, 0)),
                yEnd: .value(amountTitle, month.budget.chartValue)
            )
            .position(by: .value(seriesTitle, budgetName))
            .foregroundStyle(Color.accentColor.opacity(0.8))
            .accessibilityHidden(true)
        }
    }

    private var legend: some View {
        HStack(spacing: 16) {
            LegendSwatch(isBudget: false, name: expensesName)
            LegendSwatch(isBudget: true, name: budgetName)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .accessibilityHidden(true)
    }

    private func spokenValue(_ month: MonthlyBudgetExpense) -> String {
        [
            String(localized: "analytics.budgets.budgetValue \(month.budget.formattedAmount(currencyCode: currencyCode))"),
            String(localized: "analytics.budgets.expenseValue \(month.expense.formattedAmount(currencyCode: currencyCode))"),
        ].joined(separator: ", ")
    }
}

/// A legend square in the series' style: solid for expenses, light with a solid top for the budget.
private struct LegendSwatch: View {
    let isBudget: Bool
    let name: String

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.accentColor.opacity(isBudget ? 0.25 : 1))
                .overlay(alignment: .top) {
                    if isBudget {
                        Rectangle()
                            .fill(Color.accentColor.opacity(0.8))
                            .frame(height: 2)
                    }
                }
                .frame(width: 10, height: 10)
            Text(verbatim: name)
        }
    }
}

/// The picked month's figures above the chart, like the web's tooltip.
private struct SelectedMonthCallout: View {
    let month: MonthlyBudgetExpense
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: month.start.formattedMonth())
                .font(.caption.weight(.semibold))
            Text("analytics.budgets.budgetValue \(month.budget.formattedAmount(currencyCode: currencyCode))")
            Text("analytics.budgets.expenseValue \(month.expense.formattedAmount(currencyCode: currencyCode))")
        }
        .font(.caption)
        .monospacedDigit()
        .padding(8)
        .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 8))
    }
}

private extension MonthlyBudgetExpense {
    /// Midnight of the month's first day on the device, where the chart puts the month.
    var start: Date {
        month.start(in: .current) ?? .distantPast
    }
}

private extension [MonthlyBudgetExpense] {
    /// Skeleton bars while the year loads (`GEN-23`).
    static func placeholder(year: Int) -> [MonthlyBudgetExpense] {
        (1...12).map { number in
            MonthlyBudgetExpense(month: YearMonth(year: year, month: number), budget: 1500, expense: Decimal(1100 + number % 4 * 200))
        }
    }
}
