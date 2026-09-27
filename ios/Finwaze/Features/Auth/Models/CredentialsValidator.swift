import Foundation

/// Client-side form validation, mirroring the web sign-in and sign-up forms.
nonisolated enum CredentialsValidator {
    /// Matches `minimum_password_length` in `supabase/config.toml`.
    static let minimumPasswordLength = 8

    enum EmailIssue: Equatable {
        case required
        case invalid
    }

    enum PasswordIssue: Equatable {
        case required
        case tooShort
    }

    enum ConfirmationIssue: Equatable {
        case required
        case mismatch
    }

    static func validateEmail(_ email: String) -> EmailIssue? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return .required }
        return trimmed.wholeMatch(of: #/[^@\s]+@[^@\s]+\.[^@\s]+/#) == nil ? .invalid : nil
    }

    /// Sign-in only checks presence: the server decides whether the password is right.
    static func validateSignInPassword(_ password: String) -> PasswordIssue? {
        password.isEmpty ? .required : nil
    }

    static func validateNewPassword(_ password: String) -> PasswordIssue? {
        if password.isEmpty { return .required }
        return password.count < minimumPasswordLength ? .tooShort : nil
    }

    static func validateConfirmation(_ confirmation: String, password: String) -> ConfirmationIssue? {
        if confirmation.isEmpty { return .required }
        return confirmation != password ? .mismatch : nil
    }
}
