import SwiftUI

/// The Budget section (`BUD-10…16`): the filters, the month's total, a card per group and "Most expenses". A group's
/// card opens the group's screen (`BUD-17`); "Add budget", "Edit budget" and "Create budget" open the plan editor
/// (`BUD-20`).
struct BudgetView: View {
    let app: AppViewModel
    @Environment(\.pushRoute) private var pushRoute
    @Environment(\.zoomNamespace) private var zoomNamespace
    // Kept by the tab for the whole session, so the filters survive switching tabs (`BUD-11`).
    @State private var filter: BudgetFilter
    @State private var viewModel: BudgetViewModel
    @State private var isFiltering = false
    @State private var isAddingExpense = false
    /// "Add budget" or "Edit budget" in the navigation bar (`BUD-15`).
    @Binding var planAction: SectionToolbarAction?
    /// The plan editor is open; set by the bar's action or an empty state (`BUD-20`).
    @Binding var isPlanning: Bool

    init(app: AppViewModel, planAction: Binding<SectionToolbarAction?>, isPlanning: Binding<Bool>) {
        self.app = app
        _planAction = planAction
        _isPlanning = isPlanning
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
                    FilterSummaryBar(
                        title: viewModel.filter.month.title,
                        details: Text("filters.summary \(currencyCode) \(viewModel.filter.statusText) \(viewModel.filter.groupsText)"),
                        activeCount: viewModel.filter.activeCount,
                        onFilter: { isFiltering = true }
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
        .onChange(of: currentPlanAction, initial: true) { planAction = $1 }
        .task(for: viewModel.query, dataVersion: app.dataVersion) {
            await viewModel.load(dataVersion: app.dataVersion)
        }
        .refreshable { await viewModel.refresh() }
        .navigationDestination(for: BudgetGroupRoute.self) { route in
            BudgetGroupView(app: app, filter: filter, route: route)
                .zoomDestination(ZoomID.budgetGroup(route.id), in: zoomNamespace)
        }
        .sheet(isPresented: $isFiltering) {
            if let currencyCode = viewModel.currencyCode {
                BudgetFiltersSheet(viewModel: viewModel, currencyCode: currencyCode)
            }
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

    private var currentPlanAction: SectionToolbarAction {
        SectionToolbarAction(
            title: viewModel.hasPlan ? "budget.edit" : "budget.add",
            systemImage: viewModel.hasPlan ? "pencil" : "plus",
            // Until the totals arrive it is unknown which of the two applies.
            isEnabled: viewModel.totals.value != nil
        )
    }
}

#Preview {
    NavigationStack {
        BudgetView(app: .preview, planAction: .constant(nil), isPlanning: .constant(false))
    }
    .environment(AppViewModel.preview)
}
