import SwiftUI

/// Analytics (`ANL-01…06`): the filters, three summary cards, "Monthly overview", "Budgets vs Expenses" and
/// "Statistics", in the web's order. One column in portrait; in landscape the summary cards side by side and the
/// charts in two columns. The filters live for the session (`AnalyticsFilter` in `MainTabView`).
struct AnalyticsView: View {
    let app: AppViewModel
    @Environment(AnalyticsFilter.self) private var sessionFilter: AnalyticsFilter?
    /// Only where no session filter is given, e.g. a preview.
    @State private var ownFilter = AnalyticsFilter()

    var body: some View {
        AnalyticsContentView(app: app, filter: sessionFilter ?? ownFilter)
    }
}

private struct AnalyticsContentView: View {
    /// Reload trigger: what each card shows and every change to the data (`GEN-26`).
    private struct LoadKey: Equatable {
        let query: AnalyticsQuery?
        let yearKey: AnalyticsYearKey?
        let dataVersion: Int
    }

    let app: AppViewModel
    @State private var viewModel: AnalyticsViewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    init(app: AppViewModel, filter: AnalyticsFilter) {
        self.app = app
        _viewModel = State(initialValue: AnalyticsViewModel(
            repository: app.repositories.analytics,
            budgetRepository: app.repositories.budget,
            referenceData: app.referenceData,
            preferences: app.preferences,
            filter: filter
        ))
    }

    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }

    var body: some View {
        ScrollView {
            if let currencyCode = viewModel.currencyCode {
                VStack(spacing: 16) {
                    AnalyticsFilterBar(viewModel: viewModel, currencyCode: currencyCode)
                    summaryCards(currencyCode: currencyCode)
                    charts(currencyCode: currencyCode)
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .task(id: LoadKey(query: viewModel.query, yearKey: viewModel.yearKey, dataVersion: app.dataVersion)) {
            await viewModel.load(dataVersion: app.dataVersion)
        }
        .refreshable { await viewModel.refresh() }
    }

    @ViewBuilder
    private func summaryCards(currencyCode: String) -> some View {
        let cards = ForEach(SummaryKind.allCases, id: \.self) { kind in
            AnalyticsSummaryCard(kind: kind, state: viewModel.summary.state, currencyCode: currencyCode) {
                Task { await viewModel.summary.refresh() }
            }
        }
        if isLandscape {
            HStack(alignment: .top, spacing: 16) { cards }
        } else {
            VStack(spacing: 16) { cards }
        }
    }

    @ViewBuilder
    private func charts(currencyCode: String) -> some View {
        let cards = Group {
            MonthlyOverviewCard(viewModel: viewModel, currencyCode: currencyCode)
            BudgetsVsExpensesCard(viewModel: viewModel, currencyCode: currencyCode)
            AnalyticsStatisticsCard(viewModel: viewModel, currencyCode: currencyCode)
        }
        if isLandscape {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16, alignment: .top), count: 2), spacing: 16) {
                cards
            }
        } else {
            VStack(spacing: 16) { cards }
        }
    }
}

#Preview {
    NavigationStack {
        AnalyticsView(app: .preview)
    }
    .environment(AppViewModel.preview)
}
