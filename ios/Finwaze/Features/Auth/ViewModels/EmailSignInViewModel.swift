import Foundation
import Observation

/// Email and password sign-in (`AUTH-02`, `AUTH-03`).
@Observable
final class EmailSignInViewModel {
    var email: String
    var password = ""
    var failure: AuthFailure?
    private(set) var isSubmitting = false
    /// Field errors stay hidden until the first submit, like the web form.
    private(set) var showsValidation = false

    private let repository: any AuthRepository

    init(repository: any AuthRepository, email: String = "") {
        self.repository = repository
        self.email = email
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
        guard emailIssue == nil, passwordIssue == nil, !isSubmitting else { return }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await repository.signIn(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
        } catch {
            failure = error
        }
    }
}
