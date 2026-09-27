import SwiftUI

/// Signed in without a regular account (`NAV-07`). The tour and the first-account form come in stage 2;
/// until then the only way out is signing out (`ONB-05`).
struct OnboardingPlaceholderView: View {
    let onSignOut: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("onboarding.placeholder.title", systemImage: "sparkles")
        } description: {
            Text("onboarding.placeholder.message")
        } actions: {
            Button("profile.signOut", systemImage: "rectangle.portrait.and.arrow.right", action: onSignOut)
                .buttonStyle(.glass)
        }
    }
}

#Preview {
    OnboardingPlaceholderView(onSignOut: {})
}
