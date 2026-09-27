import Foundation

/// Offline stand-in for SwiftUI previews. Not wrapped in `#if DEBUG`: `#Preview` blocks compile in every configuration.
nonisolated struct PreviewAuthRepository: AuthRepository {
    func sessionChanges() -> AsyncStream<UserSession?> {
        AsyncStream { $0.yield(nil) }
    }

    func signIn(email: String, password: String) async throws(AuthFailure) {
        throw .invalidCredentials
    }

    func signUp(email: String, password: String) async throws(AuthFailure) -> SignUpResult {
        .confirmationRequired
    }

    func resendSignUpConfirmation(email: String) async throws(AuthFailure) {}

    func sendPasswordReset(email: String) async throws(AuthFailure) {}

    func signOut() async throws(AuthFailure) {}
}
