import SwiftUI

/// The Wallet: a card per regular account with its balance (`ACC-02`) and "Add account" (`ACC-07`).
struct WalletView: View {
    @Environment(AppViewModel.self) private var app
    @State private var viewModel: WalletViewModel
    /// "New account" is open; set by the section's "+" or the empty state.
    @Binding var isAddingAccount: Bool

    init(repository: any WalletRepository, isAddingAccount: Binding<Bool>) {
        _isAddingAccount = isAddingAccount
        _viewModel = State(initialValue: WalletViewModel(repository: repository))
    }

    var body: some View {
        content
            .sheet(isPresented: $isAddingAccount) {
                NewAccountView(app: app)
            }
            // Balances follow every change to the data: a new account or transaction (`GEN-26`).
            .task(id: app.dataVersion) { await viewModel.load() }
            .refreshable { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            AccountCardGrid(accounts: WalletAccount.placeholders)
                .redacted(reason: .placeholder)
                .allowsHitTesting(false)
                .accessibilityLabel(Text("common.loading"))
        case .loaded(let accounts) where accounts.isEmpty:
            ContentUnavailableView {
                Label("wallet.empty.title", systemImage: "wallet.bifold")
            } description: {
                Text("wallet.empty.message")
            } actions: {
                Button("wallet.addAccount", systemImage: "plus") { isAddingAccount = true }
                    .buttonStyle(.glassProminent)
            }
        case .loaded(let accounts):
            AccountCardGrid(accounts: accounts)
        case .failed:
            ContentUnavailableView {
                Label("error.generic.title", systemImage: "exclamationmark.triangle")
            } description: {
                Text("error.generic.message")
            } actions: {
                Button("common.retry", systemImage: "arrow.clockwise") {
                    Task { await viewModel.load() }
                }
                .buttonStyle(.glassProminent)
            }
        }
    }
}

private struct AccountCardGrid: View {
    let accounts: [WalletAccount]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 16)], spacing: 16) {
                ForEach(accounts) { account in
                    // Account settings open from the card in stage 6.
                    AccountCard(account: account)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

/// Name, balance with its currency and the currency code (`ACC-02`, `GEN-06`).
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
        WalletView(repository: DemoWalletRepository(), isAddingAccount: .constant(false))
    }
    .environment(AppViewModel.preview)
}
