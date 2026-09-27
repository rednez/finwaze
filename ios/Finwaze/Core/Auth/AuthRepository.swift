import Foundation

/// Outcome of a successful sign-up request.
nonisolated enum SignUpResult: Equatable, Sendable {
    /// The account is active and a session was started.
    case signedIn
    /// The backend requires e-mail confirmation before the first sign-in.
    case confirmationRequired
}

/// Domain-level auth errors, independent of the Supabase SDK.
nonisolated enum AuthFailure: Error, Equatable, Sendable {
    case invalidCredentials
    case emailNotConfirmed
    case userAlreadyExists
    case weakPassword
    case rateLimited
    case network
    case unknown(String)
}

protocol AuthRepository: Sendable {
    /// Emits `true` while the user is signed in, `false` otherwise. Starts with the state restored on launch.
    func sessionChanges() -> AsyncStream<Bool>
    func signIn(email: String, password: String) async throws(AuthFailure)
    func signInWithDemo() async throws(AuthFailure)
    func signUp(email: String, password: String) async throws(AuthFailure) -> SignUpResult
    func resendSignUpConfirmation(email: String) async throws(AuthFailure)
    func signOut() async throws(AuthFailure)
}
