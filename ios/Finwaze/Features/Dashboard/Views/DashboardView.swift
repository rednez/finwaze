import SwiftUI

/// The Dashboard (`DASH-01…08`): the primary currency, three summary cards, the monthly cash flow, this month's budget,
/// recent transactions and savings goals. One column on a phone, more on a wider screen.
struct DashboardView: View {
    /// Reload trigger: the primary currency and every change to the data (`DASH-01`, `GEN-26`).
    private struct LoadKey: Equatable {
        let currencyCode: String?
        let dataVersion: Int
    }

    @Environment(AppViewModel.self) private var app
    @Environment(MainNavigation.self) private var navigation: MainNavigation?
    @State private var viewModel: DashboardViewModel
    /// Opens a secondary section on top of the Dashboard (`NAV-02`).
    let onOpen: (AppSection) -> Void

    init(app: AppViewModel, onOpen: @escaping (AppSection) -> Void) {
        self.onOpen = onOpen
        _viewModel = State(initialValue: DashboardViewModel(
            repository: app.repositories.dashboard,
            referenceData: app.referenceData,
            preferences: app.preferences
        ))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let currencyCode = viewModel.currencyCode {
                    CurrencyMenu(
                        currencyCodes: viewModel.currencyCodes,
                        selection: currencyCode,
                        onSelect: viewModel.selectCurrency
                    )
                    cards(currencyCode: currencyCode)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .task(id: LoadKey(currencyCode: viewModel.currencyCode, dataVersion: app.dataVersion)) {
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
                    onOpenGoals: { onOpen(.goals) }
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

/// The primary currency, chosen from the currencies of the user's accounts (`DASH-01`, `GEN-11`).
private struct CurrencyMenu: View {
    let currencyCodes: [String]
    let selection: String
    let onSelect: (String) -> Void

    var body: some View {
        Menu {
            Picker("dashboard.currency", selection: Binding(get: { selection }, set: onSelect)) {
                ForEach(currencyCodes, id: \.self) { code in
                    Text(verbatim: code).tag(code)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text("dashboard.currency")
                    .foregroundStyle(.secondary)
                Text(verbatim: selection)
                    .fontWeight(.semibold)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.glass)
        .accessibilityLabel(Text("dashboard.currency"))
        .accessibilityValue(Text(verbatim: selection))
    }
}

#Preview {
    NavigationStack {
        DashboardView(app: .preview, onOpen: { _ in })
    }
    .environment(AppViewModel.preview)
}
