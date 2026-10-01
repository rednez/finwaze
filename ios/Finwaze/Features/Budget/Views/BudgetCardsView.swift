import SwiftUI

/// The cards of a Budget screen, the month's or a group's: the total, a card per group or category and "Most
/// expenses". One column on a phone; on a wider screen the budget cards on the left and the other two beside them.
struct BudgetCardsView: View {
    let viewModel: BudgetViewModel
    let currencyCode: String
    let totalsTitle: LocalizedStringKey
    /// Opens a group's screen; `nil` on a group's screen, whose cards are categories.
    var onOpenGroup: ((BudgetItem) -> Void)?
    let onPlan: () -> Void
    let onAddExpense: () -> Void
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        if sizeClass == .regular {
            HStack(alignment: .top, spacing: 16) {
                budgets
                    .frame(maxWidth: .infinity)
                VStack(spacing: 16) {
                    totals
                    expenses
                }
                .frame(width: 360)
            }
        } else {
            VStack(spacing: 16) {
                totals
                budgets
                expenses
            }
        }
    }

    /// Left out of an empty month, whose empty state already offers to create a budget (`BUD-16`).
    @ViewBuilder
    private var totals: some View {
        if !isEmptyMonth {
            BudgetTotalsCard(
                title: totalsTitle,
                state: viewModel.totals,
                currencyCode: currencyCode,
                onRetry: { retry(.totals) },
                onCreateBudget: onPlan
            )
        }
    }

    private var isEmptyMonth: Bool {
        viewModel.groupID == nil && viewModel.budgets == .loaded([])
    }

    private var expenses: some View {
        BudgetExpensesCard(
            state: viewModel.expenses,
            currencyCode: currencyCode,
            onRetry: { retry(.expenses) },
            onAddExpense: onAddExpense
        )
    }

    @ViewBuilder
    private var budgets: some View {
        switch viewModel.budgets {
        case .loading:
            grid(BudgetItem.placeholders)
                .redacted(reason: .placeholder)
                .allowsHitTesting(false)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("common.loading"))
        case .failed:
            ContentCard(title: viewModel.groupID == nil ? "budget.groups.title" : "budget.categories.title") {
                CardStateView(state: viewModel.budgets, placeholder: [], onRetry: { retry(.budgets) }) { _ in
                    EmptyView()
                }
            }
        case .loaded(let items) where items.isEmpty:
            empty
        case .loaded:
            let visible = viewModel.visibleBudgets
            if visible.isEmpty {
                ContentUnavailableView {
                    Label("budget.noMatches.title", systemImage: "line.3.horizontal.decrease.circle")
                } description: {
                    Text("budget.noMatches.message")
                } actions: {
                    Button("budget.noMatches.reset") { viewModel.filter.clearGroupFilters() }
                        .buttonStyle(.bordered)
                }
            } else {
                grid(visible)
            }
        }
    }

    /// No plan and no spending (`BUD-16`); a group's screen only gets here once its last expense and plan are gone.
    @ViewBuilder
    private var empty: some View {
        if viewModel.groupID == nil {
            ContentUnavailableView {
                Label("budget.empty.title", systemImage: "chart.pie")
            } description: {
                Text("budget.empty.message")
            } actions: {
                Button("budget.create", systemImage: "plus", action: onPlan)
                    .buttonStyle(.glassProminent)
            }
        } else {
            ContentUnavailableView {
                Label("budget.group.empty.title", systemImage: "chart.pie")
            } description: {
                Text("budget.group.empty.message")
            }
        }
    }

    private func grid(_ items: [BudgetItem]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 16, alignment: .top)], spacing: 16) {
            ForEach(items) { item in
                BudgetItemCard(
                    item: item,
                    currencyCode: currencyCode,
                    onOpen: onOpenGroup.map { open in { open(item) } }
                )
                .zoomSource(ZoomID.budgetGroup(item.id))
            }
        }
    }

    private func retry(_ card: BudgetViewModel.Card) {
        Task { await viewModel.retry(card) }
    }
}
