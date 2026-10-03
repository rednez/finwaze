import Foundation
import Synchronization
@testable import Finwaze

final class FakeAuthRepository: AuthRepository {
    struct Calls {
        var signIn: [(email: String, password: String)] = []
        var signInWithGoogle = 0
        var signInWithDemo = 0
        var signUp: [(email: String, password: String)] = []
        var resendConfirmation: [String] = []
        var passwordReset: [String] = []
        var signOut = 0
    }

    let signInFailure: AuthFailure?
    let signUpResult: Result<SignUpResult, AuthFailure>
    let resendFailure: AuthFailure?
    let resetFailure: AuthFailure?
    /// Session events emitted by `sessionChanges()`, then the stream finishes.
    let sessionEvents: [UserSession?]
    private let recorded = Mutex(Calls())

    init(
        signInFailure: AuthFailure? = nil,
        signUpResult: Result<SignUpResult, AuthFailure> = .success(.confirmationRequired),
        resendFailure: AuthFailure? = nil,
        resetFailure: AuthFailure? = nil,
        sessionEvents: [UserSession?] = []
    ) {
        self.signInFailure = signInFailure
        self.signUpResult = signUpResult
        self.resendFailure = resendFailure
        self.resetFailure = resetFailure
        self.sessionEvents = sessionEvents
    }

    var calls: Calls { recorded.withLock { $0 } }

    func sessionChanges() -> AsyncStream<UserSession?> {
        AsyncStream { continuation in
            sessionEvents.forEach { continuation.yield($0) }
            continuation.finish()
        }
    }

    func signIn(email: String, password: String) async throws(AuthFailure) {
        recorded.withLock { $0.signIn.append((email, password)) }
        if let signInFailure { throw signInFailure }
    }

    func signUp(email: String, password: String) async throws(AuthFailure) -> SignUpResult {
        recorded.withLock { $0.signUp.append((email, password)) }
        return try signUpResult.get()
    }

    func resendSignUpConfirmation(email: String) async throws(AuthFailure) {
        recorded.withLock { $0.resendConfirmation.append(email) }
        if let resendFailure { throw resendFailure }
    }

    var isGoogleSignInAvailable: Bool { true }

    func signInWithGoogle() async throws(AuthFailure) {
        recorded.withLock { $0.signInWithGoogle += 1 }
        if let signInFailure { throw signInFailure }
    }

    func signInWithDemo() async throws(AuthFailure) {
        recorded.withLock { $0.signInWithDemo += 1 }
        if let signInFailure { throw signInFailure }
    }

    func sendPasswordReset(email: String) async throws(AuthFailure) {
        recorded.withLock { $0.passwordReset.append(email) }
        if let resetFailure { throw resetFailure }
    }

    func signOut() async throws(AuthFailure) {
        recorded.withLock { $0.signOut += 1 }
    }
}
