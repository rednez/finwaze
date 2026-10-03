import SwiftUI

/// Navigation container for the signed-out part of the app.
struct AuthFlowView: View {
    let repository: any AuthRepository
    let enterDemo: () async throws(AuthFailure) -> Void

    @State private var path: [AuthRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            LoginView(repository: repository, enterDemo: enterDemo)
                .navigationDestination(for: AuthRoute.self, destination: destination)
        }
    }

    @ViewBuilder
    private func destination(_ route: AuthRoute) -> some View {
        switch route {
        case .emailSignIn(let email):
            EmailSignInView(repository: repository, email: email)
        case .signup:
            SignupView(repository: repository, onSignIn: signInWithEmail)
        case .resetPassword(let email):
            ResetPasswordView(repository: repository, email: email, onSignIn: signInWithEmail)
        }
    }

    /// After sign-up or a reset request the user signs in on the email screen, with the email filled in.
    private func signInWithEmail(_ email: String) {
        path = [.emailSignIn(email: email)]
    }
}
