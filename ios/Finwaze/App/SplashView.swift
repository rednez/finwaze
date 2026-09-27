import SwiftUI

/// Neutral screen while the session is restored and reference data loads (`NAV-09`).
struct SplashView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(height: 52)
                .accessibilityHidden(true)
            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    SplashView()
}
