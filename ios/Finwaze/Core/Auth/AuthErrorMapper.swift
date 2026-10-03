import Foundation
import Supabase

nonisolated enum AuthErrorMapper {
    static func toAuthFailure(_ error: any Error) -> AuthFailure {
        // Also covers `URLError`, which bridges to this domain.
        if (error as NSError).domain == NSURLErrorDomain {
            return .network
        }
        guard let authError = error as? AuthError else {
            return .unknown(error.localizedDescription)
        }
        switch authError.errorCode {
        case .invalidCredentials:
            return .invalidCredentials
        case .emailNotConfirmed:
            return .emailNotConfirmed
        case .userAlreadyExists, .emailExists:
            return .userAlreadyExists
        case .weakPassword:
            return .weakPassword
        case .overEmailSendRateLimit, .overRequestRateLimit:
            return .rateLimited
        default:
            return .unknown(authError.message)
        }
    }

    /// Whether a failed token refresh means the server rejected the session (as opposed to
    /// a network or server outage, after which the stored session is still worth keeping).
    static func isSessionRejected(_ error: any Error) -> Bool {
        guard case .api(_, _, _, let response) = error as? AuthError else { return false }
        return (400..<500).contains(response.statusCode)
    }
}
