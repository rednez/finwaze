import SwiftUI

/// Navigation container for the signed-out part of the app.
struct AuthFlowView: View {
    let repository: any AuthRepository

    var body: some View {
        NavigationStack {
            LoginView(repository: repository)
        }
    }
}
