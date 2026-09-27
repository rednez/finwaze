import SwiftUI

extension View {
    /// Adds the "More" menu, the section's "?" button and the profile menu to the navigation bar.
    func sectionToolbar(for section: AppSection, onOpen: @escaping (AppSection) -> Void) -> some View {
        modifier(SectionToolbar(section: section, onOpen: onOpen))
    }
}

private struct SectionToolbar: ViewModifier {
    private enum Sheet: Identifiable {
        case sectionGuide, guide, settings

        var id: Self { self }
    }

    let section: AppSection
    let onOpen: (AppSection) -> Void
    @Environment(AppViewModel.self) private var app
    @State private var sheet: Sheet?

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu("section.more", systemImage: "ellipsis") {
                        ForEach(AppSection.secondary.filter { $0 != section }, id: \.self) { destination in
                            Button(destination.title, systemImage: destination.systemImage) {
                                onOpen(destination)
                            }
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("section.help", systemImage: "questionmark.circle") {
                        sheet = .sectionGuide
                    }
                }

                ToolbarSpacer(.fixed, placement: .topBarTrailing)

                ToolbarItem(placement: .topBarTrailing) {
                    ProfileMenu(
                        email: app.user?.email,
                        isDemo: app.isDemo,
                        onGuide: { sheet = .guide },
                        onSettings: { sheet = .settings },
                        onSignOut: { Task { await app.signOut() } }
                    )
                }
            }
            .sheet(item: $sheet) { sheet in
                switch sheet {
                case .sectionGuide:
                    PlaceholderSheet(title: section.title, message: "guide.comingSoon", systemImage: "book")
                case .guide:
                    PlaceholderSheet(title: "profile.guide", message: "guide.comingSoon", systemImage: "book")
                case .settings:
                    PlaceholderSheet(title: "profile.settings", message: "settings.comingSoon", systemImage: "gearshape")
                }
            }
    }
}

/// Profile menu: Guide, Settings, Sign out (`NAV-04`). Demo mode has no settings (`AUTH-10`).
private struct ProfileMenu: View {
    let email: String?
    let isDemo: Bool
    let onGuide: () -> Void
    let onSettings: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        Menu("profile.menu", systemImage: "person.crop.circle") {
            Section {
                Button("profile.guide", systemImage: "book", action: onGuide)
                if !isDemo {
                    Button("profile.settings", systemImage: "gearshape", action: onSettings)
                }
            } header: {
                if isDemo {
                    Text("profile.demoMode")
                } else if let email {
                    Text(verbatim: email)
                }
            }

            Button("profile.signOut", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive, action: onSignOut)
        }
    }
}

/// A sheet for screens that come in later stages (Guide — stage 15, Settings — stage 14).
private struct PlaceholderSheet: View {
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let systemImage: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label(title, systemImage: systemImage)
            } description: {
                Text(message)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.done", role: .confirm) { dismiss() }
                }
            }
        }
    }
}
