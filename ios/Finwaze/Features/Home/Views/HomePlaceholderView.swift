import SwiftUI

/// Temporary signed-in screen until the real app content exists.
struct HomePlaceholderView: View {
    let session: SessionStore

    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("home.placeholder.title", systemImage: "hammer")
            } description: {
                Text("home.placeholder.message")
            } actions: {
                Button("home.signOut", systemImage: "rectangle.portrait.and.arrow.right") {
                    Task { await session.signOut() }
                }
                .buttonStyle(.glass)
            }
        }
    }
}

#Preview {
    HomePlaceholderView(session: SessionStore(repository: PreviewAuthRepository()))
}
