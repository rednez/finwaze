import SwiftUI

extension View {
    /// Adds the section's actions — the Dashboard's primary currency, "Transfer money" and "+" — and, apart from them,
    /// the profile menu to the navigation bar. The profile menu is only on a tab's root screen (`showsProfile`), not on
    /// a section pushed onto it. `onAdd` runs for "+" and `onTransfer` for "Transfer money"; sections without them
    /// (`AppSection.addTitle`, `AppSection.transferTitle`) show no such button. A screen that is not a section (`nil`,
    /// the "More" tab) gets only the profile menu. The guide lives in "More" (`NAV-03`).
    func sectionToolbar(
        for section: AppSection?,
        onAdd: @escaping () -> Void = {},
        onTransfer: @escaping () -> Void = {},
        showsProfile: Bool = true
    ) -> some View {
        modifier(SectionToolbar(
            section: section,
            onAdd: onAdd,
            onTransfer: onTransfer,
            showsProfile: showsProfile
        ))
    }
}

private struct SectionToolbar: ViewModifier {
    let section: AppSection?
    let onAdd: () -> Void
    let onTransfer: () -> Void
    let showsProfile: Bool
    @Environment(AppViewModel.self) private var app
    @State private var isShowingSettings = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                // The section's actions share one group; the profile menu stands apart after the spacer. The
                // currency is declared here, not in the Dashboard, which would put it after the profile menu.
                if section == .dashboard {
                    ToolbarItem(placement: .topBarTrailing) {
                        PrimaryCurrencyMenu()
                    }
                }

                if let transferTitle = section?.transferTitle {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(transferTitle, systemImage: "arrow.left.arrow.right", action: onTransfer)
                    }
                }

                if let addTitle = section?.addTitle {
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
                            onSettings: { isShowingSettings = true },
                            onSignOut: { Task { await app.signOut() } }
                        )
                    }
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                PlaceholderSheet(title: "profile.settings", message: "settings.comingSoon", systemImage: "gearshape")
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

/// A sheet for a screen that comes in a later stage (Settings — stage 15).
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
