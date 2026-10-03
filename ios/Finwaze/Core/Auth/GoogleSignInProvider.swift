import CryptoKit
import Foundation
import GoogleSignIn
import UIKit

/// Google's native sign-in sheet (GoogleSignIn SDK). It only obtains Google's tokens;
/// `SupabaseAuthRepository` exchanges them for a Supabase session.
/// Exists only in builds with a Google client (`GOOGLE_IOS_CLIENT_ID`).
final class GoogleSignInProvider {
    nonisolated struct Tokens: Sendable {
        let idToken: String
        let accessToken: String
        /// The raw nonce; Google put its SHA-256 into the ID token, Supabase checks that it matches.
        let nonce: String
    }

    nonisolated enum Failure: Error {
        case noPresenter
        case noIDToken
    }

    init(clientID: String) {
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    }

    /// Returns `nil` when the user closes the sheet: cancelling is not an error (`AUTH-06`).
    func signIn() async throws -> Tokens? {
        guard let presenter = Self.topViewController() else { throw Failure.noPresenter }
        let nonce = Self.randomNonce()
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: presenter,
                hint: nil,
                additionalScopes: nil,
                nonce: Self.sha256(nonce)
            )
            guard let idToken = result.user.idToken?.tokenString else { throw Failure.noIDToken }
            return Tokens(idToken: idToken, accessToken: result.user.accessToken.tokenString, nonce: nonce)
        } catch let error as GIDSignInError where error.code == .canceled {
            return nil
        }
    }

    /// Forgets the Google account, so the next sign-in shows the account picker again.
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }

    /// Passes the sign-in callback URL (`GOOGLE_IOS_URL_SCHEME`) back to the SDK.
    func handle(_ url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }

    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        var controller = scene?.keyWindow?.rootViewController
        while let presented = controller?.presentedViewController {
            controller = presented
        }
        return controller
    }

    private static func randomNonce() -> String {
        (0..<32).map { _ in String(format: "%02x", UInt8.random(in: .min ... .max)) }.joined()
    }

    private static func sha256(_ value: String) -> String {
        SHA256.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
