import SwiftUI

/// A primary section's tab, with the section as the first screen of its stack.
struct SectionView: View {
    let section: AppSection
    @State private var path = NavigationPath()

    var body: some View {
        TabStack(path: $path) {
            SectionContentView(section: section)
        }
    }
}

/// A tab's navigation stack; secondary sections (in "More"), transactions, transfers and account settings are pushed
/// onto it (`NAV-02`, `TX-06`, `TRF-07`, `ACC-02`).
struct TabStack<Root: View>: View {
    @Binding var path: NavigationPath
    @ViewBuilder let root: Root
    @Environment(AppViewModel.self) private var app

    var body: some View {
        NavigationStack(path: $path) {
            root
                .navigationDestination(for: AppSection.self) { destination in
                    SectionContentView(section: destination, isRoot: false)
                }
                .navigationDestination(for: TransactionRoute.self) { route in
                    EditTransactionView(app: app, transactionID: route.id)
                }
                .navigationDestination(for: TransferRoute.self) { route in
                    TransferDetailsView(app: app, transactionID: route.transactionID)
                }
                .navigationDestination(for: AccountRoute.self) { route in
                    AccountSettingsView(app: app, accountID: route.id)
                }
        }
        .environment(\.pushRoute, PushRouteAction { route in path.append(route) })
    }
}

/// One section's screen: title, short description, the section's actions and the menus (`NAV-03`, `NAV-04`).
/// Sections whose stage is not implemented yet show a placeholder.
struct SectionContentView: View {
    let section: AppSection
    /// The tab's first screen rather than a section pushed onto it: only it shows the profile menu (`NAV-04`).
    var isRoot = true
    @Environment(AppViewModel.self) private var app
    /// The section's "+" was tapped; the section presents its own form.
    @State private var isAdding = false
    /// The section's "Transfer money" was tapped (`ACC-01`).
    @State private var isTransferring = false

    var body: some View {
        content
            .navigationTitle(section.title)
            .navigationSubtitle(section.subtitle)
            .sectionToolbar(
                for: section,
                onAdd: { isAdding = true },
                onTransfer: { isTransferring = true },
                showsProfile: isRoot
            )
    }

    @ViewBuilder
    private var content: some View {
        switch section {
        case .dashboard:
            DashboardView(app: app)
        case .transactions:
            TransactionsView(app: app, isAdding: $isAdding)
        case .wallet:
            WalletView(
                app: app,
                isAddingAccount: $isAdding,
                isTransferring: $isTransferring
            )
        case .groups:
            GroupsView(app: app, isAddingGroup: $isAdding)
        case .budget:
            BudgetView(app: app)
        case .goals:
            GoalsView(app: app, isAdding: $isAdding)
        default:
            ContentUnavailableView {
                Label(section.title, systemImage: section.systemImage)
            } description: {
                Text("section.comingSoon")
            }
        }
    }
}

#Preview {
    SectionView(section: .dashboard)
        .environment(AppViewModel.preview)
}
