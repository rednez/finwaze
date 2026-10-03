import Foundation

/// Screens pushed onto the signed-out navigation stack (`AuthFlowView`).
enum AuthRoute: Hashable {
    /// Email and password (`AUTH-02`), with the email filled in when coming back from sign-up or reset.
    case emailSignIn(email: String)
    case signup
    case resetPassword(email: String)
}
