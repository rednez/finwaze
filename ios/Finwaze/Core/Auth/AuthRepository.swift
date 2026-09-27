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

/// The signed-in user, as far as the app needs to know it.
nonisolated struct UserSession: Equatable, Sendable {
    let userID: UUID
    let email: String?
    /// Profile picture, e.g. from Google or the seeded demo account (`user_metadata.avatar_url`).
    var avatarURL: URL?
}

protocol AuthRepository: Sendable {
    /// Emits the signed-in user, or `nil` while signed out. Starts with the state restored on launch.
    func sessionChanges() -> AsyncStream<UserSession?>
    func signIn(email: String, password: String) async throws(AuthFailure)
    /// Signs in to the shared server demo account; demo data itself stays local (`AUTH-10`, `Q-08`).
    func signInWithDemo() async throws(AuthFailure)
    func signUp(email: String, password: String) async throws(AuthFailure) -> SignUpResult
    func resendSignUpConfirmation(email: String) async throws(AuthFailure)
    /// Emails a password-reset link. Succeeds whether or not an account exists for `email`.
    func sendPasswordReset(email: String) async throws(AuthFailure)
    func signOut() async throws(AuthFailure)
}
