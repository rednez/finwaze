import SwiftUI

/// The Goals section (`GOAL-10…17`): the filters, a card per goal with "Deposit" and "Withdraw", "Total goals" and
/// the savings overview. The section's "+" and the empty state open "New goal"; a card opens the goal's screen.
struct GoalsView: View {
    /// Reload trigger: the filters and every change to the data (`GEN-26`).
    private struct LoadKey: Equatable {
        let query: GoalsQuery
        let dataVersion: Int
    }

    /// "Deposit" or "Withdraw" on a card (`GOAL-12`).
    private struct TransferRequest: Identifiable {
        let goal: SavingsGoal
        let direction: GoalTransferViewModel.Direction

        var id: String { "\(goal.id)-\(direction)" }
    }

    let app: AppViewModel
    /// The section's "+" (`GOAL-10`).
    @Binding var isAdding: Bool
    @Environment(\.pushRoute) private var pushRoute
    @State private var viewModel: GoalsViewModel
    @State private var transferRequest: TransferRequest?

    init(app: AppViewModel, isAdding: Binding<Bool>) {
        self.app = app
        _isAdding = isAdding
        _viewModel = State(initialValue: GoalsViewModel(repository: app.repositories.goals))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                GoalsFilterCard(viewModel: viewModel)
                goals
                if viewModel.goals.value?.isEmpty == false {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 340), spacing: 16, alignment: .top)], spacing: 16) {
                        GoalsSummaryCard(state: summaryState) { retryGoals() }
                        overview
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .overlay(alignment: .top) {
            if let banner = viewModel.banner {
                SuccessBanner(message: banner) { viewModel.banner = nil }
            }
        }
        .task(id: LoadKey(query: viewModel.query, dataVersion: app.dataVersion)) {
            await viewModel.load(dataVersion: app.dataVersion)
        }
        .refreshable { await viewModel.refresh() }
        .navigationDestination(for: GoalRoute.self) { route in
            GoalDetailView(app: app, goalID: route.id) { message in
                withAnimation { viewModel.banner = message }
            }
        }
        .sheet(isPresented: $isAdding) {
            NewGoalView(app: app)
        }
        .sheet(item: $transferRequest) { request in
            GoalTransferView(app: app, goal: request.goal, direction: request.direction) { message in
                withAnimation { viewModel.banner = message }
            }
        }
    }

    @ViewBuilder
    private var goals: some View {
        switch viewModel.goals {
        case .loading:
            goalGrid(DemoData.savingsGoals())
                .redacted(reason: .placeholder)
                .allowsHitTesting(false)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("common.loading"))
        case .failed:
            ContentUnavailableView {
                Label("error.generic.title", systemImage: "exclamationmark.triangle")
            } description: {
                Text("error.generic.message")
            } actions: {
                Button("common.retry", systemImage: "arrow.clockwise", action: retryGoals)
                    .buttonStyle(.glassProminent)
            }
        case .loaded(let goals) where goals.isEmpty:
            emptyState
        case .loaded(let goals):
            goalGrid(goals)
        }
    }

    private func goalGrid(_ goals: [SavingsGoal]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 16, alignment: .top)], spacing: 16) {
            ForEach(goals) { goal in
                GoalCard(
                    goal: goal,
                    onOpen: { pushRoute(GoalRoute(id: goal.id)) },
                    onDeposit: { transferRequest = TransferRequest(goal: goal, direction: .deposit) },
                    onWithdraw: { transferRequest = TransferRequest(goal: goal, direction: .withdraw) }
                )
            }
        }
    }

    /// No goals at all, or none under these filters, which "Add goal" would not fix (`GOAL-17`).
    @ViewBuilder
    private var emptyState: some View {
        if viewModel.narrowsGoals {
            ContentUnavailableView {
                Label("goals.empty.filtered.title", systemImage: "line.3.horizontal.decrease.circle")
            } description: {
                Text("goals.empty.filtered.message")
            }
        } else {
            ContentUnavailableView {
                Label("goals.empty.title", systemImage: "target")
            } description: {
                Text("goals.empty.message")
            } actions: {
                Button("goals.add", systemImage: "plus") { isAdding = true }
                    .buttonStyle(.glassProminent)
            }
        }
    }

    @ViewBuilder
    private var overview: some View {
        if let currencyCode = viewModel.overviewCurrencyCode {
            SavingsOverviewCard(
                state: viewModel.overview,
                year: viewModel.year,
                currencyCodes: viewModel.overviewCurrencyCodes,
                currencyCode: currencyCode,
                onSelectCurrency: { code in Task { await viewModel.selectOverviewCurrency(code) } },
                onRetry: { Task { await viewModel.retryOverview() } }
            )
        }
    }

    private var summaryState: CardState<GoalsSummary> {
        viewModel.summary.map(CardState.loaded) ?? .loading
    }

    private func retryGoals() {
        Task { await viewModel.retryGoals() }
    }
}

#Preview {
    NavigationStack {
        GoalsView(app: .preview, isAdding: .constant(false))
    }
    .environment(AppViewModel.preview)
}
