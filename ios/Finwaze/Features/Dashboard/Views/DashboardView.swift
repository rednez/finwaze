import SwiftUI

/// The Dashboard (`DASH-01…08`): three summary cards, the monthly cash flow, this month's budget, recent transactions
/// and savings goals. The primary currency is chosen in the navigation bar (`PrimaryCurrencyMenu`, `SectionToolbar`).
/// One column on a phone, more on a wider screen.
struct DashboardView: View {
    @Environment(AppViewModel.self) private var app
    @Environment(MainNavigation.self) private var navigation: MainNavigation?
    @State private var viewModel: DashboardViewModel

    init(app: AppViewModel) {
        _viewModel = State(initialValue: DashboardViewModel(
            repository: app.repositories.dashboard,
            preferences: app.preferences
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let currencyCode = viewModel.currencyCode {
                    cards(currencyCode: currencyCode)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .task(for: viewModel.currencyCode, dataVersion: app.dataVersion) {
            await viewModel.load(dataVersion: app.dataVersion)
        }
        .refreshable { await viewModel.refresh() }
    }

    private func cards(currencyCode: String) -> some View {
        VStack(spacing: 16) {
            // The balance across the top, income and expenses side by side under it.
            summaryCard(.balance, currencyCode: currencyCode)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16, alignment: .top)], spacing: 16) {
                summaryCard(.income, currencyCode: currencyCode)
                summaryCard(.expenses, currencyCode: currencyCode)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 340), spacing: 16, alignment: .top)], spacing: 16) {
                CashFlowCard(state: viewModel.cashFlow, currencyCode: currencyCode) {
                    retry(.cashFlow)
                }
                BudgetCard(
                    state: viewModel.budget,
                    currencyCode: currencyCode,
                    onRetry: { retry(.budget) },
                    onOpenBudget: { navigation?.open(.budget) }
                )
                RecentTransactionsCard(
                    state: viewModel.recentTransactions,
                    onRetry: { retry(.recentTransactions) },
                    onOpenTransactions: { navigation?.open(.transactions) }
                )
                SavingsGoalsCard(
                    state: viewModel.goals,
                    onRetry: { retry(.goals) },
                    onOpenGoals: { navigation?.open(.goals) }
                )
            }
        }
    }

    private func summaryCard(_ kind: SummaryKind, currencyCode: String) -> some View {
        SummaryCard(kind: kind, state: viewModel.totals, currencyCode: currencyCode) {
            retry(.totals)
        }
    }

    private func retry(_ card: DashboardViewModel.Card) {
        Task { await viewModel.retry(card) }
    }
}

#Preview {
    NavigationStack {
        DashboardView(app: .preview)
    }
    .environment(AppViewModel.preview)
}
