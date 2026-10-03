import SwiftUI

/// Full-width prominent button that shows a spinner while the request is running.
struct SubmitButton: View {
  let title: LocalizedStringKey
  let isLoading: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      LoadingButtonLabel(isLoading: isLoading) {
        Text(title)
      }
    }
    .buttonStyle(.glassProminent)
    .disabled(isLoading)
  }
}

#Preview("Idle") {
  SubmitButton(title: "login.submit", isLoading: false) {}
    .padding()
}

#Preview("Loading") {
  SubmitButton(title: "login.submit", isLoading: true) {}
    .padding()
}
