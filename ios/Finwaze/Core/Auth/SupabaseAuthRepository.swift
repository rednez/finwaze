import Foundation
import Supabase

nonisolated struct SupabaseAuthRepository: AuthRepository {
    let client: SupabaseClient
    /// The web client of this environment; reset links open its "set a new password" page.
    var webAppURL: URL?

    func sessionChanges() -> AsyncStream<UserSession?> {
        let changes = client.auth.authStateChanges
        return AsyncStream { continuation in
            let task = Task {
                for await (event, session) in changes {
                    guard let session else {
                        continuation.yield(nil)
                        continue
                    }
                    let user = UserSession(userID: session.user.id, email: session.user.email)
                    if event == .initialSession, session.isExpired {
                        // Resolve the stored session before leaving the launch screen, so an expired
                        // token doesn't flash the login screen while it is being refreshed.
                        continuation.yield(await restoreExpiredSession() ? user : nil)
                    } else {
                        continuation.yield(user)
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

    func sendPasswordReset(email: String) async throws(AuthFailure) {
        do {
            try await client.auth.resetPasswordForEmail(
                email,
                redirectTo: webAppURL?.appending(path: "change-password")
            )
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
