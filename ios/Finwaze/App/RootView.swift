import SwiftUI

/// Switches between the auth flow and the signed-in content based on the session.
struct RootView: View {
    let authRepository: any AuthRepository
    @State private var session: SessionStore

    init(authRepository: any AuthRepository) {
        self.authRepository = authRepository
        _session = State(initialValue: SessionStore(repository: authRepository))
    }

    var body: some View {
        Group {
            switch session.state {
            case .loading:
                ProgressView()
            case .signedOut:
                AuthFlowView(repository: authRepository)
            case .signedIn:
                HomePlaceholderView(session: session)
            }
        }
        .animation(.default, value: session.state)
        .task { await session.observeSession() }
    }
}
