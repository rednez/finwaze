import SwiftUI

/// Shown when the data needed after sign-in could not be loaded (`GEN-25`).
struct LoadFailedView: View {
    let onRetry: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        ScreenErrorView(onRetry: onRetry) {
            Button("profile.signOut", action: onSignOut)
                .buttonStyle(.glass)
        }
    }
}

#Preview {
    LoadFailedView(onRetry: {}, onSignOut: {})
}
