import Foundation
import Observation

/// The sign-in method picker (`AUTH-01`): Google and demo mode start right here; email has its own screen.
@Observable
final class LoginViewModel {
    enum SignInMethod {
        case google, demo
    }

    var failure: AuthFailure?
    /// The sign-in request in progress; each button shows its own spinner.
    private(set) var pendingMethod: SignInMethod?

    private let repository: any AuthRepository
    /// Opens demo mode (`AUTH-10`).
    private let enterDemo: () async throws(AuthFailure) -> Void

    init(repository: any AuthRepository, enterDemo: @escaping () async throws(AuthFailure) -> Void = {}) {
        self.repository = repository
        self.enterDemo = enterDemo
    }

    var isGoogleSignInAvailable: Bool {
        repository.isGoogleSignInAvailable
    }

    func signInWithGoogle() async {
        await perform(.google) { [repository] () async throws(AuthFailure) in
            try await repository.signInWithGoogle()
        }
    }

    func signInWithDemo() async {
        await perform(.demo) { [enterDemo] () async throws(AuthFailure) in
            try await enterDemo()
        }
    }

    var isSubmitting: Bool {
        pendingMethod != nil
    }

    private func perform(_ method: SignInMethod, _ action: () async throws(AuthFailure) -> Void) async {
        guard pendingMethod == nil else { return }
        pendingMethod = method
        defer { pendingMethod = nil }

        do {
            try await action()
        } catch {
            failure = error
        }
    }
}
