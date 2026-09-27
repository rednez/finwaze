import Foundation
import Observation

@Observable
final class LoginViewModel {
    enum SignInMethod {
        case email, demo
    }

    var email = ""
    var password = ""
    var failure: AuthFailure?
    /// The sign-in request in progress; each button shows its own spinner.
    private(set) var pendingMethod: SignInMethod?
    /// Field errors stay hidden until the first submit, like the web form.
    private(set) var showsValidation = false

    private let repository: any AuthRepository
    /// Opens demo mode (`AUTH-10`).
    private let enterDemo: () async throws(AuthFailure) -> Void

    init(repository: any AuthRepository, enterDemo: @escaping () async throws(AuthFailure) -> Void = {}) {
        self.repository = repository
        self.enterDemo = enterDemo
    }

    var emailIssue: CredentialsValidator.EmailIssue? {
        showsValidation ? CredentialsValidator.validateEmail(email) : nil
    }

    var passwordIssue: CredentialsValidator.PasswordIssue? {
        showsValidation ? CredentialsValidator.validateSignInPassword(password) : nil
    }

    /// On success the session store switches the app to the signed-in content.
    func signIn() async {
        showsValidation = true
        guard emailIssue == nil, passwordIssue == nil else { return }

        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        await perform(.email) { [repository, password] () async throws(AuthFailure) in
            try await repository.signIn(email: email, password: password)
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
