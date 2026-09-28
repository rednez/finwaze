import SwiftUI

extension View {
    /// Adds the "More" menu (other sections, the section's guide article and the guide), the section's actions — the
    /// Dashboard's primary currency, "Transfer money" and "+" — and, apart from them, the profile menu to the navigation
    /// bar. The profile menu is only on a tab's root screen (`showsProfile`), not on a section pushed onto it. `onAdd` runs for "+" and `onTransfer` for "Transfer money"; sections without them
    /// (`AppSection.addTitle`, `AppSection.transferTitle`) show no such button.
    func sectionToolbar(
        for section: AppSection,
        onOpen: @escaping (AppSection) -> Void,
        onAdd: @escaping () -> Void = {},
        onTransfer: @escaping () -> Void = {},
        showsProfile: Bool = true
    ) -> some View {
        modifier(SectionToolbar(
            section: section,
            onOpen: onOpen,
            onAdd: onAdd,
            onTransfer: onTransfer,
            showsProfile: showsProfile
        ))
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
    let onTransfer: () -> Void
    let showsProfile: Bool
    @Environment(AppViewModel.self) private var app
    @State private var sheet: Sheet?
    @State private var isConfirmingSignOut = false

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

                        // Help lives here rather than in the bar, which keeps the bar for the section's actions.
                        Section {
                            Button("section.help", systemImage: "questionmark.circle") {
                                sheet = .sectionGuide
                            }
                            Button("profile.guide", systemImage: "book") {
                                sheet = .guide
                            }
                        }
                    }
                }

                // The section's actions share one group; the profile menu stands apart after the spacer. The
                // currency is declared here, not in the Dashboard, which would put it after the profile menu.
                if section == .dashboard {
                    ToolbarItem(placement: .topBarTrailing) {
                        PrimaryCurrencyMenu()
                    }
                }

                if let transferTitle = section.transferTitle {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(transferTitle, systemImage: "arrow.left.arrow.right", action: onTransfer)
                    }
                }

                if let addTitle = section.addTitle {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(addTitle, systemImage: "plus", action: onAdd)
                    }
                }

                if showsProfile {
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)

                    ToolbarItem(placement: .topBarTrailing) {
                        ProfileMenu(
                            email: app.user?.email,
                            avatarURL: app.user?.avatarURL,
                            isDemo: app.isDemo,
                            onSettings: { sheet = .settings },
                            onSignOut: { isConfirmingSignOut = true }
                        )
                        // Confirmed first, as a sign-out is two taps away on every tab (`AUTH-11`).
                        .confirmationDialog(
                            "profile.signOut.confirmTitle",
                            isPresented: $isConfirmingSignOut,
                            titleVisibility: .visible
                        ) {
                            Button("profile.signOut", role: .destructive) {
                                Task { await app.signOut() }
                            }
                            Button("common.cancel", role: .cancel) {}
                        }
                    }
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

/// Profile menu: Settings, Sign out (`NAV-04`). Demo mode has no settings (`AUTH-10`).
private struct ProfileMenu: View {
    let email: String?
    let avatarURL: URL?
    let isDemo: Bool
    let onSettings: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        Menu {
            // One section: in demo mode it has only "Sign out", which still needs the header above it.
            Section {
                if !isDemo {
                    Button("profile.settings", systemImage: "gearshape", action: onSettings)
                }
                Button(
                    "profile.signOut",
                    systemImage: "rectangle.portrait.and.arrow.right",
                    role: .destructive,
                    action: onSignOut
                )
            } header: {
                if isDemo {
                    Text("profile.demoMode")
                } else if let email {
                    Text(verbatim: email)
                }
            }
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

/// A sheet for screens that come in later stages (Guide — stage 14, Settings — stage 15).
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
