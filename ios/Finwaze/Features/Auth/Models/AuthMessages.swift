import Foundation

/// User-facing texts for validation issues and auth failures.
extension CredentialsValidator.EmailIssue {
    var message: LocalizedStringResource {
        switch self {
        case .required: "auth.emailRequired"
        case .invalid: "auth.emailInvalid"
        }
    }
}

extension CredentialsValidator.PasswordIssue {
    var message: LocalizedStringResource {
        switch self {
        case .required: "auth.passwordRequired"
        case .tooShort: "signup.passwordTooShort"
        }
    }
}

extension CredentialsValidator.ConfirmationIssue {
    var message: LocalizedStringResource {
        switch self {
        case .required: "signup.confirmRequired"
        case .mismatch: "signup.passwordsMismatch"
        }
    }
}

extension AuthFailure {
    var message: LocalizedStringResource {
        switch self {
        case .invalidCredentials: "auth.error.invalidCredentials"
        case .emailNotConfirmed: "auth.error.emailNotConfirmed"
        case .userAlreadyExists: "auth.error.userExists"
        case .weakPassword: "auth.error.weakPassword"
        case .rateLimited: "auth.error.rateLimited"
        case .network: "auth.error.network"
        case .unknown(let details): "auth.error.unknown \(details)"
        }
    }
}
