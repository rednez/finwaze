import SwiftUI

/// Soft brand glow behind the auth and onboarding screens.
struct BrandBackground: View {
  var body: some View {
    ZStack {
      Color(.systemBackground)
      RadialGradient(
        colors: [.brandGradientStart.opacity(0.18), .clear],
        center: .top,
        startRadius: 0,
        endRadius: 420
      )
    }
    .ignoresSafeArea()
  }
}
