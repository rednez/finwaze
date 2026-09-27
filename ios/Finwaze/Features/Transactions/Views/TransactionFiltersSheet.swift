import SwiftUI

/// The list's filters in a bottom sheet (`TX-03`): type, currency, account, group and category. Changes apply right
/// away; the currency narrows the accounts and the group the categories (`TX-04`). The month stays on the list.
struct TransactionFiltersSheet: View {
    @Bindable var viewModel: TransactionsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("transactions.filters.type") {
                    Picker("transactions.filters.type", selection: $viewModel.filters.type) {
                        Text("transactions.filters.all").tag(TransactionType?.none)
                        ForEach(TransactionType.filterable, id: \.self) { type in
                            Text(type.filterTitle).tag(TransactionType?.some(type))
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                Section {
                    Picker("transactions.filters.currency", selection: $viewModel.filters.currencyCode) {
                        Text("transactions.filters.all").tag(String?.none)
                        ForEach(viewModel.currencyCodes, id: \.self) { code in
                            Text(verbatim: code).tag(String?.some(code))
                        }
                    }
                    Picker("transactions.filters.account", selection: $viewModel.filters.accountID) {
                        Text("transactions.filters.all").tag(Int64?.none)
                        ForEach(viewModel.accounts) { account in
                            Text(verbatim: account.name).tag(Int64?.some(account.id))
                        }
                    }
                }

                Section {
                    Picker("transactions.filters.group", selection: $viewModel.filters.groupID) {
                        Text("transactions.filters.all").tag(Int64?.none)
                        ForEach(viewModel.groups) { group in
                            Text(verbatim: group.name).tag(Int64?.some(group.id))
                        }
                    }
                    Picker("transactions.filters.category", selection: $viewModel.filters.categoryID) {
                        Text("transactions.filters.all").tag(Int64?.none)
                        ForEach(viewModel.categories) { category in
                            Text(verbatim: category.name).tag(Int64?.some(category.id))
                        }
                    }
                    .disabled(viewModel.filters.groupID == nil)
                } footer: {
                    if viewModel.filters.groupID == nil {
                        Text("transactions.filters.categoryHint")
                    }
                }
            }
            .navigationTitle("transactions.filters.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("transactions.filters.reset") { viewModel.filters.reset() }
                        .disabled(viewModel.filters.activeCount == 0)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.done", role: .confirm) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

/// The filters in use, as small chips under the month; each one clears its filter.
struct ActiveFilterChips: View {
    @Bindable var viewModel: TransactionsViewModel

    private struct Chip: Identifiable {
        let id: String
        let title: Text
        let clear: () -> Void
    }

    var body: some View {
        if !chips.isEmpty {
            ScrollView(.horizontal) {
                GlassEffectContainer(spacing: 8) {
                    HStack(spacing: 8) {
                        ForEach(chips) { chip in
                            Button(action: chip.clear) {
                                HStack(spacing: 6) {
                                    chip.title
                                        .lineLimit(1)
                                    Image(systemName: "xmark")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.secondary)
                                }
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                            .glassEffect(.regular.interactive(), in: .capsule)
                            .accessibilityLabel(chip.title)
                            .accessibilityHint(Text("transactions.filters.removeHint"))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 2)
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var chips: [Chip] {
        let filters = viewModel.filters
        var chips: [Chip] = []
        if let type = filters.type {
            chips.append(Chip(id: "type", title: Text(type.filterTitle)) { viewModel.filters.type = nil })
        }
        if let code = filters.currencyCode {
            chips.append(Chip(id: "currency", title: Text(verbatim: code)) { viewModel.filters.currencyCode = nil })
        }
        if let account = viewModel.accounts.first(where: { $0.id == filters.accountID }) {
            chips.append(Chip(id: "account", title: Text(verbatim: account.name)) { viewModel.filters.accountID = nil })
        }
        if let group = viewModel.groups.first(where: { $0.id == filters.groupID }) {
            chips.append(Chip(id: "group", title: Text(verbatim: group.name)) { viewModel.filters.groupID = nil })
        }
        if let category = viewModel.categories.first(where: { $0.id == filters.categoryID }) {
            chips.append(Chip(id: "category", title: Text(verbatim: category.name)) { viewModel.filters.categoryID = nil })
        }
        return chips
    }
}

extension TransactionType {
    /// The types the list can be filtered by (`TX-03`).
    static let filterable: [TransactionType] = [.expense, .income, .transfer]

    var filterTitle: LocalizedStringKey {
        switch self {
        case .expense: "transactionType.expense"
        case .income: "transactionType.income"
        case .transfer, .internal: "transactionType.transfer"
        }
    }
}

#Preview {
    @Previewable @State var viewModel = TransactionsViewModel(
        repository: DemoTransactionsRepository(),
        referenceData: ReferenceDataStore()
    )
    Color.clear.sheet(isPresented: .constant(true)) {
        TransactionFiltersSheet(viewModel: viewModel)
    }
}
