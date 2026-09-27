import Foundation
import Observation

/// App-wide authentication state; decides whether the auth flow or the main app is shown.
@Observable
final class SessionStore {
    enum State: Equatable {
        case loading
        case signedOut
        case signedIn
    }

    private(set) var state: State = .loading

    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    /// Follows session changes for as long as the calling task lives.
    func observeSession() async {
        for await isSignedIn in repository.sessionChanges() {
            state = isSignedIn ? .signedIn : .signedOut
        }
    }

    func signOut() async {
        // A failed server-side sign-out still clears the local session, so there is nothing to report.
        try? await repository.signOut()
    }
}
