import SwiftUI

extension View {
    /// Adds the "More" menu, the section's "?" and "+" buttons and, apart from them, the profile menu to the
    /// navigation bar. `onAdd` runs for "+"; sections without one (`AppSection.addTitle`) show no "+".
    func sectionToolbar(
        for section: AppSection,
        onOpen: @escaping (AppSection) -> Void,
        onAdd: @escaping () -> Void = {}
    ) -> some View {
        modifier(SectionToolbar(section: section, onOpen: onOpen, onAdd: onAdd))
    }
}

private struct SectionToolbar: ViewModifier {
    private enum Sheet: Identifiable {
        case sectionGuide, guide, settings

        var id: Self { self }
    }

    let section: AppSection
    let onOpen: (AppSection) -> Void
    let onAdd: () -> Void
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

                // "?" and "+" share one group; the profile menu stands apart after the spacer.
                ToolbarItem(placement: .topBarTrailing) {
                    Button("section.help", systemImage: "questionmark.circle") {
                        sheet = .sectionGuide
                    }
                }

                if let addTitle = section.addTitle {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(addTitle, systemImage: "plus", action: onAdd)
                    }
                }

                ToolbarSpacer(.fixed, placement: .topBarTrailing)

                ToolbarItem(placement: .topBarTrailing) {
                    ProfileMenu(
                        email: app.user?.email,
                        avatarURL: app.user?.avatarURL,
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
    let avatarURL: URL?
    let isDemo: Bool
    let onGuide: () -> Void
    let onSettings: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        Menu {
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
        } label: {
            UserAvatar(url: avatarURL)
        }
        .accessibilityLabel(Text("profile.menu"))
    }
}

/// The user's profile picture, or a generic person icon when there is none or it fails to load.
private struct UserAvatar: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(.circle)
            } else {
                Image(systemName: "person.crop.circle")
            }
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
