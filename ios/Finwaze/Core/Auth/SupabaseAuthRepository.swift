import Foundation
import Supabase

nonisolated struct SupabaseAuthRepository: AuthRepository {
    // Seeded demo account, same as the web client.
    private static let demoEmail = "demo@mail.com"
    private static let demoPassword = "password1234"

    let client: SupabaseClient

    func sessionChanges() -> AsyncStream<Bool> {
        let changes = client.auth.authStateChanges
        return AsyncStream { continuation in
            let task = Task {
                for await (event, session) in changes {
                    guard let session else {
                        continuation.yield(false)
                        continue
                    }
                    if event == .initialSession, session.isExpired {
                        // Resolve the stored session before leaving the launch screen, so an expired
                        // token doesn't flash the login screen while it is being refreshed.
                        continuation.yield(await restoreExpiredSession())
                    } else {
                        continuation.yield(true)
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Refreshes an expired stored session. Only a rejection by the server signs the user out:
    /// without a network the user stays signed in and the SDK retries the refresh later.
    private func restoreExpiredSession() async -> Bool {
        do {
            _ = try await client.auth.session
            return true
        } catch {
            guard AuthErrorMapper.isSessionRejected(error) else { return true }
            try? await client.auth.signOut(scope: .local)
            return false
        }
    }

    func signIn(email: String, password: String) async throws(AuthFailure) {
        do {
            try await client.auth.signIn(email: email, password: password)
        } catch {
            throw AuthErrorMapper.toAuthFailure(error)
        }
    }

    func signInWithDemo() async throws(AuthFailure) {
        try await signIn(email: Self.demoEmail, password: Self.demoPassword)
    }

    func signUp(email: String, password: String) async throws(AuthFailure) -> SignUpResult {
        do {
            let response = try await client.auth.signUp(email: email, password: password)
            return response.session == nil ? .confirmationRequired : .signedIn
        } catch {
            throw AuthErrorMapper.toAuthFailure(error)
        }
    }

    func resendSignUpConfirmation(email: String) async throws(AuthFailure) {
        do {
            try await client.auth.resend(email: email, type: .signup)
        } catch {
            throw AuthErrorMapper.toAuthFailure(error)
        }
    }

    func signOut() async throws(AuthFailure) {
        do {
            try await client.auth.signOut()
        } catch {
            throw AuthErrorMapper.toAuthFailure(error)
        }
    }
}
