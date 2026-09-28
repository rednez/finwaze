import SwiftUI

/// Analytics' filters (`ANL-01`): "‹ September 2026 ›", the currency and its accounts. The chips share a row, or go
/// one under the other when they do not fit, e.g. at the largest text sizes.
struct AnalyticsFilterBar: View {
    let viewModel: AnalyticsViewModel
    let currencyCode: String

    var body: some View {
        VStack(spacing: 16) {
            MonthStepper(month: viewModel.filter.month, onShift: viewModel.shiftMonth(by:))
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    chips
                }
                VStack(alignment: .leading, spacing: 8) {
                    chips
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 28))
    }

    @ViewBuilder
    private var chips: some View {
        CurrencyFilterMenu(
            title: "wallet.filter.currency",
            currencyCodes: viewModel.currencyCodes,
            selection: currencyCode,
            onSelect: viewModel.selectCurrency
        )
        AccountsFilterMenu(viewModel: viewModel)
    }
}

/// "All accounts ⌄", "Main Card ⌄" or "2 accounts ⌄": the currency's accounts to count, several at a time, so the
/// menu stays open while they are ticked.
private struct AccountsFilterMenu: View {
    let viewModel: AnalyticsViewModel

    private var selected: [Account] {
        viewModel.accounts.filter { viewModel.selectedAccountIDs.contains($0.id) }
    }

    var body: some View {
        Menu {
            Toggle("analytics.filter.allAccounts", isOn: Binding(
                get: { viewModel.selectedAccountIDs.isEmpty },
                set: { if $0 { viewModel.selectAllAccounts() } }
            ))
            Section {
                ForEach(viewModel.accounts) { account in
                    Toggle(isOn: Binding(
                        get: { viewModel.selectedAccountIDs.contains(account.id) },
                        set: { viewModel.setAccount(account.id, isSelected: $0) }
                    )) {
                        Text(verbatim: account.name)
                    }
                }
            }
        } label: {
            FilterChip(systemImage: "creditcard", value: title)
        }
        .menuActionDismissBehavior(.disabled)
        .buttonStyle(.plain)
        .accessibilityLabel(Text("analytics.filter.accounts"))
        .accessibilityValue(spokenValue)
    }

    private var title: Text {
        switch selected.count {
        case 0: Text("analytics.filter.allAccounts")
        case 1: Text(verbatim: selected[0].name)
        default: Text("analytics.filter.accountsSelected \(selected.count)")
        }
    }

    /// Every picked account by name, not only how many.
    private var spokenValue: Text {
        selected.isEmpty
            ? Text("analytics.filter.allAccounts")
            : Text(verbatim: selected.map(\.name).formatted(.list(type: .and)))
    }
}
