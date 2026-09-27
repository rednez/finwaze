import SwiftUI

/// Navigation container for the signed-out part of the app.
struct AuthFlowView: View {
    let repository: any AuthRepository
    let enterDemo: () async throws(AuthFailure) -> Void

    var body: some View {
        NavigationStack {
            LoginView(repository: repository, enterDemo: enterDemo)
        }
    }
}
