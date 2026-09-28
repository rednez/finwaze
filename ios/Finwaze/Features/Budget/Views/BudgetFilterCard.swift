import SwiftUI

/// The Budget's filters (`BUD-11`) — "‹ September 2026 ›", currency, status and groups — and "Add budget" or "Edit
/// budget" (`BUD-15`).
struct BudgetFilterCard: View {
    let viewModel: BudgetViewModel
    let currencyCode: String
    let onChooseGroups: () -> Void
    let onPlan: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            MonthStepper(month: viewModel.filter.month, onShift: viewModel.shiftMonth(by:))

            // One row that scrolls when the chips do not fit, e.g. at the largest text sizes.
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    filters
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 2)
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, -20)

            Button(action: onPlan) {
                Label(
                    viewModel.hasPlan ? "budget.edit" : "budget.add",
                    systemImage: viewModel.hasPlan ? "pencil" : "plus"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            // Until the totals arrive it is unknown which of the two applies.
            .disabled(viewModel.totals.value == nil)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 28))
    }

    @ViewBuilder
    private var filters: some View {
        CurrencyFilterMenu(
            title: "budget.filter.currency",
            currencyCodes: viewModel.currencyCodes,
            selection: currencyCode,
            onSelect: viewModel.selectCurrency
        )

        Menu {
            Picker("budget.filter.status", selection: Binding(
                get: { viewModel.filter.status },
                set: { viewModel.filter.status = $0 }
            )) {
                Text("budget.filter.allStatuses").tag(BudgetStatus?.none)
                ForEach(BudgetStatus.allCases, id: \.self) { status in
                    Label(status.title, systemImage: status.systemImage).tag(BudgetStatus?.some(status))
                }
            }
        } label: {
            FilterChip(systemImage: viewModel.filter.status?.systemImage ?? "circle.dashed", value: statusText)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("budget.filter.status"))
        .accessibilityValue(statusText)

        Button(action: onChooseGroups) {
            FilterChip(systemImage: "folder", value: groupsText)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("budget.filter.groups"))
        .accessibilityValue(groupsText)
    }

    private var statusText: Text {
        viewModel.filter.status.map { Text($0.title) } ?? Text("budget.filter.allStatuses")
    }

    private var groupsText: Text {
        let count = viewModel.filter.groupIDs.count
        return count == 0 ? Text("budget.filter.allGroups") : Text("budget.filter.groupsSelected \(count)")
    }
}
