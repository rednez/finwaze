import Foundation
import Synchronization
@testable import Finwaze

final class FakeAuthRepository: AuthRepository {
    struct Calls {
        var signIn: [(email: String, password: String)] = []
        var signInWithDemo = 0
        var signUp: [(email: String, password: String)] = []
        var resendConfirmation: [String] = []
    }

    let signInFailure: AuthFailure?
    let signUpResult: Result<SignUpResult, AuthFailure>
    let resendFailure: AuthFailure?
    private let recorded = Mutex(Calls())

    init(
        signInFailure: AuthFailure? = nil,
        signUpResult: Result<SignUpResult, AuthFailure> = .success(.confirmationRequired),
        resendFailure: AuthFailure? = nil
    ) {
        self.signInFailure = signInFailure
        self.signUpResult = signUpResult
        self.resendFailure = resendFailure
    }

    var calls: Calls { recorded.withLock { $0 } }

    func sessionChanges() -> AsyncStream<Bool> {
        AsyncStream { $0.finish() }
    }

    func signIn(email: String, password: String) async throws(AuthFailure) {
        recorded.withLock { $0.signIn.append((email, password)) }
        if let signInFailure { throw signInFailure }
    }

    func signInWithDemo() async throws(AuthFailure) {
        recorded.withLock { $0.signInWithDemo += 1 }
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

    func signOut() async throws(AuthFailure) {}
}
