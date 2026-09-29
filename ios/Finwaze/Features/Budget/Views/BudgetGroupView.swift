import SwiftUI

/// A group's budget (`BUD-17`): the group's total, a card per category and the categories' "Most expenses", in the
/// month and currency of the Budget screen it was opened from.
struct BudgetGroupView: View {
    let app: AppViewModel
    let route: BudgetGroupRoute
    @State private var viewModel: BudgetViewModel
    @State private var isPlanning = false
    @State private var isAddingExpense = false

    init(app: AppViewModel, filter: BudgetFilter, route: BudgetGroupRoute) {
        self.app = app
        self.route = route
        _viewModel = State(initialValue: BudgetViewModel(
            repository: app.repositories.budget,
            referenceData: app.referenceData,
            preferences: app.preferences,
            filter: filter,
            groupID: route.id
        ))
    }

    var body: some View {
        ScrollView {
            if let currencyCode = viewModel.currencyCode {
                BudgetCardsView(
                    viewModel: viewModel,
                    currencyCode: currencyCode,
                    totalsTitle: "budget.group.totals.title",
                    onPlan: { isPlanning = true },
                    onAddExpense: { isAddingExpense = true }
                )
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        // "Budget · September 2026 · UAH" under the group's name (`BUD-10`).
        .navigationTitle(Text(verbatim: route.name))
        .navigationSubtitle(Text("budget.group.subtitle \(viewModel.filter.month.title) \(viewModel.currencyCode ?? "")"))
        .task(for: viewModel.query, dataVersion: app.dataVersion) {
            await viewModel.load(dataVersion: app.dataVersion)
        }
        .refreshable { await viewModel.refresh() }
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
