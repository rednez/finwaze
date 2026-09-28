import SwiftUI

/// The Budget section (`BUD-10…16`): the filters, the month's total, a card per group and "Most expenses". A group's
/// card opens the group's screen (`BUD-17`); "Add budget", "Edit budget" and "Create budget" open the plan editor
/// (`BUD-20`).
struct BudgetView: View {
    /// Reload trigger: the month, the currency and every change to the data (`GEN-26`).
    private struct LoadKey: Equatable {
        let query: BudgetQuery?
        let dataVersion: Int
    }

    let app: AppViewModel
    @Environment(\.pushRoute) private var pushRoute
    // Kept by the tab for the whole session, so the filters survive switching tabs (`BUD-11`).
    @State private var filter: BudgetFilter
    @State private var viewModel: BudgetViewModel
    @State private var isChoosingGroups = false
    @State private var isPlanning = false
    @State private var isAddingExpense = false

    init(app: AppViewModel) {
        self.app = app
        let filter = BudgetFilter()
        _filter = State(initialValue: filter)
        _viewModel = State(initialValue: BudgetViewModel(
            repository: app.repositories.budget,
            referenceData: app.referenceData,
            preferences: app.preferences,
            filter: filter
        ))
    }

    var body: some View {
        ScrollView {
            if let currencyCode = viewModel.currencyCode {
                VStack(spacing: 16) {
                    BudgetFilterCard(
                        viewModel: viewModel,
                        currencyCode: currencyCode,
                        onChooseGroups: { isChoosingGroups = true },
                        onPlan: { isPlanning = true }
                    )
                    BudgetCardsView(
                        viewModel: viewModel,
                        currencyCode: currencyCode,
                        totalsTitle: "budget.totals.title",
                        onOpenGroup: { group in
                            pushRoute(BudgetGroupRoute(id: group.id, name: group.name))
                        },
                        onPlan: { isPlanning = true },
                        onAddExpense: { isAddingExpense = true }
                    )
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .task(id: LoadKey(query: viewModel.query, dataVersion: app.dataVersion)) {
            await viewModel.load(dataVersion: app.dataVersion)
        }
        .refreshable { await viewModel.refresh() }
        .navigationDestination(for: BudgetGroupRoute.self) { route in
            BudgetGroupView(app: app, filter: filter, route: route)
        }
        .sheet(isPresented: $isChoosingGroups) {
            BudgetGroupsSheet(options: viewModel.groupOptions, filter: filter)
        }
        // The whole month's plan, from a group's screen too: a plan is set per month, not per group (`BUD-20`).
        .sheet(isPresented: $isPlanning) {
            if let currencyCode = viewModel.currencyCode {
                BudgetPlanView(app: app, month: viewModel.filter.month, currencyCode: currencyCode)
            }
        }
        .sheet(isPresented: $isAddingExpense) {
            NewTransactionView(app: app)
        }
    }
}

#Preview {
    NavigationStack {
        BudgetView(app: .preview)
    }
    .environment(AppViewModel.preview)
}
