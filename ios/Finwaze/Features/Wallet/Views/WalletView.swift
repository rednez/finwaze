import SwiftUI

/// The Wallet: a card per regular account with its balance (`ACC-02`), "Transfer money" (`ACC-01`, `TRF`), "Add
/// account" (`ACC-07`) and, under the accounts, three widgets with their own filters: daily cash flow, recent
/// transactions and statistics (`ACC-03…06`).
struct WalletView: View {
    let app: AppViewModel
    @Environment(MainNavigation.self) private var navigation: MainNavigation?
    @State private var viewModel: WalletViewModel
    // Kept by the tab for the whole session, so each widget's filters survive switching tabs (`ACC-06`).
    @State private var cashFlow: DailyCashFlowViewModel
    @State private var recentTransactions: WalletWidgetViewModel<[Transaction]>
    @State private var statistics: WalletStatisticsViewModel
    @State private var isAddingTransaction = false
    /// "New account" is open; set by the section's "+" or the empty state.
    @Binding var isAddingAccount: Bool
    /// "Transfer money" is open; set by the section's toolbar button.
    @Binding var isTransferring: Bool

    init(app: AppViewModel, isAddingAccount: Binding<Bool>, isTransferring: Binding<Bool>) {
        self.app = app
        _isAddingAccount = isAddingAccount
        _isTransferring = isTransferring
        let repository = app.repositories.wallet
        _viewModel = State(initialValue: WalletViewModel(repository: repository))
        _cashFlow = State(initialValue: DailyCashFlowViewModel(
            repository: repository, referenceData: app.referenceData, preferences: app.preferences
        ))
        _recentTransactions = State(initialValue: .recentTransactions(
            repository: repository, referenceData: app.referenceData, preferences: app.preferences
        ))
        _statistics = State(initialValue: WalletStatisticsViewModel(
            repository: repository, referenceData: app.referenceData, preferences: app.preferences
        ))
    }

    var body: some View {
        content
            .sheet(isPresented: $isAddingAccount) {
                NewAccountView(app: app)
            }
            .sheet(isPresented: $isTransferring) {
                TransferView(app: app)
            }
            .sheet(isPresented: $isAddingTransaction) {
                NewTransactionView(app: app)
            }
            // Balances follow every change to the data: a new account or transaction (`GEN-26`).
            .task(id: app.dataVersion) { await viewModel.load() }
            .refreshable { await refresh() }
    }

    @ViewBuilder
    private var content: some View {
        if case .loaded(let accounts) = viewModel.state, accounts.isEmpty {
            ContentUnavailableView {
                Label("wallet.empty.title", systemImage: "wallet.bifold")
            } description: {
                Text("wallet.empty.message")
            } actions: {
                Button("wallet.addAccount", systemImage: "plus") { isAddingAccount = true }
                    .buttonStyle(.glassProminent)
            }
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    accounts
                    widgets
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    /// The account cards with their own loading and error states, so a failure leaves the widgets be (`GEN-25`).
    @ViewBuilder
    private var accounts: some View {
        switch viewModel.state {
        case .loading:
            AccountCardGrid(accounts: WalletAccount.placeholders)
                .redacted(reason: .placeholder)
                .allowsHitTesting(false)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("common.loading"))
        case .loaded(let accounts):
            AccountCardGrid(accounts: accounts)
        case .failed:
            ContentCard(title: "wallet.accounts.title") {
                CardErrorView { Task { await viewModel.load() } }
            }
        }
    }

    private var widgets: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 340), spacing: 16, alignment: .top)], spacing: 16) {
            DailyCashFlowCard(viewModel: cashFlow, dataVersion: app.dataVersion)
            WalletRecentTransactionsCard(
                widget: recentTransactions,
                dataVersion: app.dataVersion,
                onOpenTransactions: { navigation?.open(.transactions) },
                onAddTransaction: { isAddingTransaction = true }
            )
            WalletStatisticsCard(viewModel: statistics, dataVersion: app.dataVersion)
        }
    }

    /// Pull to refresh: the accounts and every widget, keeping their figures until the new ones arrive.
    private func refresh() async {
        async let accounts: Void = viewModel.load()
        async let cashFlow: Void = cashFlow.widget.refresh()
        async let recent: Void = recentTransactions.refresh()
        async let statistics: Void = statistics.widget.refresh()
        _ = await (accounts, cashFlow, recent, statistics)
    }
}

private struct AccountCardGrid: View {
    let accounts: [WalletAccount]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 16)], spacing: 16) {
            ForEach(accounts) { account in
                // Account settings (`ACC-02`, `ACC-09`).
                NavigationLink(value: AccountRoute(id: account.id)) {
                    AccountCard(account: account)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// Name, balance with its currency and the currency code (`ACC-02`, `GEN-06`), with a chevron hinting it opens.
private struct AccountCard: View {
    let account: WalletAccount

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: account.name)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(verbatim: account.currencyCode)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.fill.tertiary, in: .capsule)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            Text(verbatim: account.balance.formattedAmount(currencyCode: account.currencyCode))
                .font(.title2.weight(.semibold))
                .monospacedDigit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }
}

private extension WalletAccount {
    /// Skeleton cards while the accounts load (`GEN-23`).
    static let placeholders = (1...3).map {
        WalletAccount(id: -Int64($0), name: "Account name", currencyCode: "USD", balance: 1234.56)
    }
}

#Preview {
    NavigationStack {
        WalletView(app: .preview, isAddingAccount: .constant(false), isTransferring: .constant(false))
    }
    .environment(AppViewModel.preview)
}
