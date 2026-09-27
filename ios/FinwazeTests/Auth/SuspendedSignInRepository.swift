import Foundation
@testable import Finwaze

/// Holds `signIn(email:password:)` open until the test resumes it, to observe in-flight state.
final class SuspendedSignInRepository: AuthRepository {
    private let called = AsyncStream<Void>.makeStream()
    private let release = AsyncStream<Void>.makeStream()

    func waitUntilCalled() async {
        var iterator = called.stream.makeAsyncIterator()
        _ = await iterator.next()
    }

    func resume() {
        release.continuation.yield()
    }

    func signIn(email: String, password: String) async throws(AuthFailure) {
        called.continuation.yield()
        var iterator = release.stream.makeAsyncIterator()
        _ = await iterator.next()
    }

    func signInWithDemo() async throws(AuthFailure) {}
    func sessionChanges() -> AsyncStream<UserSession?> { AsyncStream { $0.finish() } }
    func signUp(email: String, password: String) async throws(AuthFailure) -> SignUpResult { .confirmationRequired }
    func resendSignUpConfirmation(email: String) async throws(AuthFailure) {}
    func sendPasswordReset(email: String) async throws(AuthFailure) {}
    func signOut() async throws(AuthFailure) {}
}
