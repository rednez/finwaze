import SwiftUI

/// "Don't have an account? Sign up" — a prompt followed by a navigation link.
struct AuthRedirectLink: View {
    let prompt: LocalizedStringKey
    let linkLabel: LocalizedStringKey
    let route: AuthRoute

    var body: some View {
        HStack(spacing: 4) {
            Text(prompt)
                .foregroundStyle(.secondary)
            NavigationLink(linkLabel, value: route)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}
