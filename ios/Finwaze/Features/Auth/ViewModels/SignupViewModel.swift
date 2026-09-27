import Foundation
import Observation

@Observable
final class SignupViewModel {
    var email = ""
    var password = ""
    var confirmation = ""
    var failure: AuthFailure?
    private(set) var isSubmitting = false
    /// The address the confirmation email went to; set once sign-up succeeds.
    private(set) var confirmationEmail: String?
    private(set) var isResending = false
    var resendFailure: AuthFailure?
    private(set) var didResend = false
    /// Field errors stay hidden until the first submit, like the web form.
    private(set) var showsValidation = false

    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    var isConfirmationEmailSent: Bool {
        confirmationEmail != nil
    }

    var emailIssue: CredentialsValidator.EmailIssue? {
        showsValidation ? CredentialsValidator.validateEmail(email) : nil
    }

    var passwordIssue: CredentialsValidator.PasswordIssue? {
        showsValidation ? CredentialsValidator.validateNewPassword(password) : nil
    }

    var confirmationIssue: CredentialsValidator.ConfirmationIssue? {
        showsValidation ? CredentialsValidator.validateConfirmation(confirmation, password: password) : nil
    }

    func signUp() async {
        showsValidation = true
        guard !isSubmitting, emailIssue == nil, passwordIssue == nil, confirmationIssue == nil else { return }

        isSubmitting = true
        defer { isSubmitting = false }

        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let result = try await repository.signUp(email: email, password: password)
            // `.signedIn` needs no handling here: the session store switches to the signed-in content.
            if result == .confirmationRequired {
                confirmationEmail = email
            }
        } catch .userAlreadyExists {
            // Never reveal that an account exists: show the same result as a successful sign-up.
            confirmationEmail = email
        } catch {
            failure = error
        }
    }

    func resendConfirmation() async {
        guard let confirmationEmail, !isResending else { return }

        isResending = true
        defer { isResending = false }

        do {
            try await repository.resendSignUpConfirmation(email: confirmationEmail)
            didResend = true
        } catch {
            resendFailure = error
        }
    }
}
