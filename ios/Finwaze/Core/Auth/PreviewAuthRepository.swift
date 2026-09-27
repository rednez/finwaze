#if DEBUG
import Foundation

/// Offline stand-in for SwiftUI previews.
nonisolated struct PreviewAuthRepository: AuthRepository {
    func sessionChanges() -> AsyncStream<Bool> {
        AsyncStream { $0.yield(false) }
    }

    func signIn(email: String, password: String) async throws(AuthFailure) {
        throw .invalidCredentials
    }

    func signInWithDemo() async throws(AuthFailure) {}

    func signUp(email: String, password: String) async throws(AuthFailure) -> SignUpResult {
        .confirmationRequired
    }

    func resendSignUpConfirmation(email: String) async throws(AuthFailure) {}

    func signOut() async throws(AuthFailure) {}
}
#endif
