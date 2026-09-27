import Foundation
import Observation

@Observable
final class ResetPasswordViewModel {
    var email: String
    var failure: AuthFailure?
    private(set) var isSubmitting = false
    /// The address the reset link went to; set once the request succeeds.
    private(set) var sentEmail: String?
    /// Field errors stay hidden until the first submit, like the web form.
    private(set) var showsValidation = false

    private let repository: any AuthRepository

    init(repository: any AuthRepository, email: String = "") {
        self.repository = repository
        self.email = email
    }

    var isLinkSent: Bool {
        sentEmail != nil
    }

    var emailIssue: CredentialsValidator.EmailIssue? {
        showsValidation ? CredentialsValidator.validateEmail(email) : nil
    }

    /// Always ends with "check your email" on success, whether or not the account exists (`AUTH-08`).
    func sendLink() async {
        showsValidation = true
        guard !isSubmitting, emailIssue == nil else { return }

        isSubmitting = true
        defer { isSubmitting = false }

        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try await repository.sendPasswordReset(email: email)
            sentEmail = email
        } catch {
            failure = error
        }
    }
}
