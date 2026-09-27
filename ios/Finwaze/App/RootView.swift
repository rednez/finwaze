import SwiftUI

/// Switches between the auth flow, onboarding and the main app (`NAV-06…09`).
struct RootView: View {
    let authRepository: any AuthRepository
    @State private var app: AppViewModel

    init(app: AppViewModel, authRepository: any AuthRepository) {
        self.authRepository = authRepository
        _app = State(initialValue: app)
    }

    var body: some View {
        Group {
            switch app.route {
            case .launching:
                SplashView()
            case .signedOut:
                AuthFlowView(repository: authRepository, enterDemo: app.enterDemo)
            case .onboarding:
                OnboardingPlaceholderView(onSignOut: signOut)
            case .main:
                MainTabView()
            case .failed:
                LoadFailedView(onRetry: { Task { await app.retry() } }, onSignOut: signOut)
            }
        }
        .animation(.default, value: app.route)
        .environment(app)
        .task { await app.observeSession() }
    }

    private func signOut() {
        Task { await app.signOut() }
    }
}
