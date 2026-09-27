import SwiftUI

/// Shown when the data needed after sign-in could not be loaded (`GEN-25`).
struct LoadFailedView: View {
    let onRetry: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("error.generic.title", systemImage: "exclamationmark.triangle")
        } description: {
            Text("error.generic.message")
        } actions: {
            Button("common.retry", systemImage: "arrow.clockwise", action: onRetry)
                .buttonStyle(.glassProminent)
            Button("profile.signOut", action: onSignOut)
                .buttonStyle(.glass)
        }
    }
}

#Preview {
    LoadFailedView(onRetry: {}, onSignOut: {})
}
