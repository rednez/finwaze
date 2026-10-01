import SwiftUI

/// The Budget's filters in a bottom sheet (`BUD-11`): the month, the currency, the status and the groups. Changes
/// apply right away; "Reset" brings back every status and group and leaves the month and currency.
struct BudgetFiltersSheet: View {
    let viewModel: BudgetViewModel
    let currencyCode: String

    var body: some View {
        FiltersSheet(canReset: viewModel.filter.activeCount > 0, onReset: viewModel.filter.clearGroupFilters) {
            FilterPeriodSection(title: "filters.month") {
                MonthStepper(month: viewModel.filter.month, onShift: viewModel.shiftMonth(by:))
            }

            Section {
                CurrencyCodePicker(title: "budget.filter.currency", codes: viewModel.currencyCodes, selection: currencyCode, onSelect: viewModel.selectCurrency)

                Picker("budget.filter.status", selection: Binding(
                    get: { viewModel.filter.status },
                    set: { viewModel.filter.status = $0 }
                )) {
                    Text("budget.filter.allStatuses").tag(BudgetStatus?.none)
                    ForEach(BudgetStatus.allCases, id: \.self) { status in
                        Label(status.title, systemImage: status.systemImage).tag(BudgetStatus?.some(status))
                    }
                }

                NavigationLink {
                    BudgetGroupsList(options: viewModel.groupOptions, filter: viewModel.filter)
                } label: {
                    LabeledContent("budget.filter.groups") {
                        viewModel.filter.groupsText
                    }
                }
            }
        }
    }
}

/// The group filter (`BUD-11`): any number of the month's groups; none picked means every group.
struct BudgetGroupsList: View {
    let options: [BudgetItem]
    let filter: BudgetFilter

    var body: some View {
        List {
            Section {
                row(title: Text("budget.filter.allGroups"), isSelected: filter.groupIDs.isEmpty) {
                    filter.groupIDs = []
                }
            }
            Section {
                ForEach(options) { group in
                    row(title: Text(verbatim: group.name), isSelected: filter.groupIDs.contains(group.id)) {
                        toggle(group.id)
                    }
                }
            }
        }
        .navigationTitle(Text("budget.filter.groups"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(title: Text, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                title
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(.tint)
                }
            }
            .contentShape(.rect)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func toggle(_ id: Int64) {
        if filter.groupIDs.contains(id) {
            filter.groupIDs.remove(id)
        } else {
            filter.groupIDs.insert(id)
        }
    }
}

extension BudgetFilter {
    /// Status and groups set beyond "All"; the month and currency always have a value.
    var activeCount: Int {
        (status == nil ? 0 : 1) + (groupIDs.isEmpty ? 0 : 1)
    }

    var statusText: Text {
        status.map { Text($0.title) } ?? Text("budget.filter.allStatuses")
    }

    var groupsText: Text {
        groupIDs.isEmpty ? Text("budget.filter.allGroups") : Text("budget.filter.groupsSelected \(groupIDs.count)")
    }
}
