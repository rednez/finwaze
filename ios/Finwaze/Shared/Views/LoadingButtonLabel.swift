import SwiftUI

/// Full-width button label that swaps its content for a spinner while the request is running.
struct LoadingButtonLabel<Content: View>: View {
  let isLoading: Bool
  @ViewBuilder let content: Content

  var body: some View {
    ZStack {
      content.opacity(isLoading ? 0 : 1)
      if isLoading {
        ProgressView()
      }
    }
    .font(.headline)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 6)
  }
}
