import SwiftUI

/// A primary section with its own navigation stack; secondary sections are pushed onto it (`NAV-02`).
struct SectionView: View {
    let section: AppSection
    @State private var path: [AppSection] = []

    var body: some View {
        NavigationStack(path: $path) {
            SectionContentView(section: section, onOpen: open)
                .navigationDestination(for: AppSection.self) { destination in
                    SectionContentView(section: destination, onOpen: open)
                }
        }
    }

    private func open(_ destination: AppSection) {
        path.append(destination)
    }
}

/// One section's screen: title, short description, "?", the section's "+" and the menus (`NAV-03`, `NAV-04`).
/// Sections whose stage is not implemented yet show a placeholder.
struct SectionContentView: View {
    let section: AppSection
    let onOpen: (AppSection) -> Void
    @Environment(AppViewModel.self) private var app
    /// The section's "+" was tapped; the section presents its own form.
    @State private var isAdding = false

    var body: some View {
        content
            .navigationTitle(section.title)
            .navigationSubtitle(section.subtitle)
            .sectionToolbar(for: section, onOpen: onOpen, onAdd: { isAdding = true })
    }

    @ViewBuilder
    private var content: some View {
        switch section {
        case .transactions:
            TransactionsView(app: app, isAdding: $isAdding)
        case .wallet:
            WalletView(repository: app.repositories.wallet, isAddingAccount: $isAdding)
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
