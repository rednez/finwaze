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

/// One section's screen: title, short description, "?" and the menus (`NAV-03`, `NAV-04`).
/// The content is a placeholder until the section's stage is implemented.
struct SectionContentView: View {
    let section: AppSection
    let onOpen: (AppSection) -> Void

    var body: some View {
        ContentUnavailableView {
            Label(section.title, systemImage: section.systemImage)
        } description: {
            Text("section.comingSoon")
        }
        .navigationTitle(section.title)
        .navigationSubtitle(section.subtitle)
        .sectionToolbar(for: section, onOpen: onOpen)
    }
}

#Preview {
    SectionView(section: .dashboard)
        .environment(AppViewModel.preview)
}
