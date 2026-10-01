import SwiftUI

/// Analytics' filters in a bottom sheet (`ANL-01`): the month, the currency and which of its accounts count, several
/// at a time. "Reset" counts every account again; the month and currency stay.
struct AnalyticsFiltersSheet: View {
    let viewModel: AnalyticsViewModel
    let currencyCode: String

    var body: some View {
        FiltersSheet(canReset: viewModel.activeFilterCount > 0, onReset: viewModel.selectAllAccounts) {
            FilterPeriodSection(title: "filters.month") {
                MonthStepper(month: viewModel.filter.month, onShift: viewModel.shiftMonth(by:))
            }

            Section {
                CurrencyCodePicker(codes: viewModel.currencyCodes, selection: currencyCode, onSelect: viewModel.selectCurrency)
            }

            Section("analytics.filter.accounts") {
                Toggle("analytics.filter.allAccounts", isOn: Binding(
                    get: { viewModel.selectedAccountIDs.isEmpty },
                    set: { if $0 { viewModel.selectAllAccounts() } }
                ))
                ForEach(viewModel.accounts) { account in
                    Toggle(isOn: Binding(
                        get: { viewModel.selectedAccountIDs.contains(account.id) },
                        set: { viewModel.setAccount(account.id, isSelected: $0) }
                    )) {
                        Text(verbatim: account.name)
                    }
                }
            }
        }
    }
}

extension AnalyticsViewModel {
    /// Accounts narrowed beyond "All accounts"; the month and currency always have a value.
    var activeFilterCount: Int {
        selectedAccountIDs.isEmpty ? 0 : 1
    }

    /// "All accounts", "Main Card" or "2 accounts".
    var accountsText: Text {
        let selected = accounts.filter { selectedAccountIDs.contains($0.id) }
        return switch selected.count {
        case 0: Text("analytics.filter.allAccounts")
        case 1: Text(verbatim: selected[0].name)
        default: Text("analytics.filter.accountsSelected \(selected.count)")
        }
    }
}
