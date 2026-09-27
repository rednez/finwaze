import SwiftUI

/// Full-width prominent button that shows a spinner while the request is running.
struct AuthSubmitButton: View {
  let title: LocalizedStringKey
  let isLoading: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      ZStack {
        Text(title).opacity(isLoading ? 0 : 1)
        if isLoading {
          ProgressView()
        }
      }
      .font(.headline)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 6)
    }
    .buttonStyle(.glassProminent)
    .disabled(isLoading)
  }
}

#Preview("Idle") {
  AuthSubmitButton(title: "login.submit", isLoading: false) {}
    .padding()
}

#Preview("Loading") {
  AuthSubmitButton(title: "login.submit", isLoading: true) {}
    .padding()
}
