import SwiftUI

/// The list's filters in one scrolling row (`TX-03`): month, type, currency, account, group and, once a group is
/// chosen, category. Each shows its name while set to "All" and the chosen value otherwise.
struct TransactionFiltersBar: View {
    @Bindable var viewModel: TransactionsViewModel

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                MonthSwitcher(month: viewModel.filters.month) { viewModel.filters.shiftMonth(by: $0) }
                typeMenu
                currencyMenu
                accountMenu
                groupMenu
                if viewModel.filters.groupID != nil {
                    categoryMenu
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
    }

    private var typeMenu: some View {
        FilterMenu(
            name: "transactions.filters.type",
            value: viewModel.filters.type.map { Text($0.filterTitle) },
            selection: $viewModel.filters.type
        ) {
            ForEach([TransactionType.expense, .income, .transfer], id: \.self) { type in
                Text(type.filterTitle).tag(TransactionType?.some(type))
            }
        }
    }

    private var currencyMenu: some View {
        FilterMenu(
            name: "transactions.filters.currency",
            value: viewModel.filters.currencyCode.map { Text(verbatim: $0) },
            selection: $viewModel.filters.currencyCode
        ) {
            ForEach(viewModel.currencyCodes, id: \.self) { code in
                Text(verbatim: code).tag(String?.some(code))
            }
        }
    }

    private var accountMenu: some View {
        FilterMenu(
            name: "transactions.filters.account",
            value: selectedName(viewModel.filters.accountID, in: viewModel.accounts),
            selection: $viewModel.filters.accountID
        ) {
            ForEach(viewModel.accounts) { account in
                Text(verbatim: account.name).tag(Int64?.some(account.id))
            }
        }
    }

    private var groupMenu: some View {
        FilterMenu(
            name: "transactions.filters.group",
            value: selectedName(viewModel.filters.groupID, in: viewModel.groups),
            selection: $viewModel.filters.groupID
        ) {
            ForEach(viewModel.groups) { group in
                Text(verbatim: group.name).tag(Int64?.some(group.id))
            }
        }
    }

    private var categoryMenu: some View {
        FilterMenu(
            name: "transactions.filters.category",
            value: selectedName(viewModel.filters.categoryID, in: viewModel.categories),
            selection: $viewModel.filters.categoryID
        ) {
            ForEach(viewModel.categories) { category in
                Text(verbatim: category.name).tag(Int64?.some(category.id))
            }
        }
    }

    private func selectedName<Item: Identifiable<Int64> & Named>(_ id: Int64?, in items: [Item]) -> Text? {
        id.flatMap { id in items.first { $0.id == id } }.map { Text(verbatim: $0.name) }
    }
}

/// Something with a user-given name: an account, group or category.
protocol Named {
    var name: String { get }
}

extension Account: Named {}
extension CategoryGroup: Named {}
extension Category: Named {}

/// A filter chip that opens a menu of "All" and the options, with a checkmark on the current one.
private struct FilterMenu<Value: Hashable, Options: View>: View {
    let name: LocalizedStringKey
    /// The chosen option's title; `nil` while the filter is "All".
    let value: Text?
    @Binding var selection: Value?
    @ViewBuilder let options: Options

    var body: some View {
        Menu {
            Picker(name, selection: $selection) {
                Text("transactions.filters.all").tag(Value?.none)
                options
            }
        } label: {
            HStack(spacing: 4) {
                (value ?? Text(name))
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.semibold))
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .foregroundStyle(value == nil ? AnyShapeStyle(.primary) : AnyShapeStyle(.tint))
            .background(value == nil ? AnyShapeStyle(.fill.tertiary) : AnyShapeStyle(.tint.opacity(0.15)), in: .capsule)
        }
        .accessibilityLabel(Text(name))
        .accessibilityValue(value ?? Text("transactions.filters.all"))
    }
}

/// "‹ September 2026 ›" — the month filter (`GEN-14`).
private struct MonthSwitcher: View {
    let month: Date
    let onShift: (Int) -> Void

    var body: some View {
        HStack(spacing: 2) {
            Button("transactions.filters.previousMonth", systemImage: "chevron.left") { onShift(-1) }
            Text(verbatim: month.formattedMonth())
                .font(.subheadline.weight(.semibold))
                .fixedSize()
            Button("transactions.filters.nextMonth", systemImage: "chevron.right") { onShift(1) }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(.fill.tertiary, in: .capsule)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("transactions.filters.month"))
    }
}

private extension TransactionType {
    var filterTitle: LocalizedStringKey {
        switch self {
        case .expense: "transactionType.expense"
        case .income: "transactionType.income"
        case .transfer, .internal: "transactionType.transfer"
        }
    }
}

#Preview {
    TransactionFiltersBar(
        viewModel: TransactionsViewModel(repository: DemoTransactionsRepository(), referenceData: ReferenceDataStore())
    )
}
