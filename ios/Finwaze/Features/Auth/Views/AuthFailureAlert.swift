import SwiftUI

extension View {
    /// Shows an alert while `failure` is set and clears it on dismissal.
    /// `title` names the action that failed, e.g. "Sign-in failed".
    func authFailureAlert(_ failure: Binding<AuthFailure?>, title: LocalizedStringKey) -> some View {
        alert(
            title,
            isPresented: Binding(
                get: { failure.wrappedValue != nil },
                set: { if !$0 { failure.wrappedValue = nil } }
            ),
            presenting: failure.wrappedValue
        ) { _ in
            Button("common.ok", role: .cancel) {}
        } message: { failure in
            Text(failure.message)
        }
    }
}
