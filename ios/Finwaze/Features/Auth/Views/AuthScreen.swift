import SwiftUI

struct AuthScreen<Content: View>: View {
  let title: LocalizedStringKey?
  let subtitle: LocalizedStringKey?
  @ViewBuilder let content: Content

  var body: some View {
    ScrollView {
      VStack(spacing: 32) {
        header
        content
      }
      .padding(24)
      .frame(maxWidth: 440)
      .frame(maxWidth: .infinity)
    }
    .scrollDismissesKeyboard(.interactively)
    .background { BrandBackground() }
  }

  private var header: some View {
    VStack(spacing: 12) {
      Image(.logo)
        .resizable()
        .scaledToFit()
        .frame(height: 52)
        .padding(.bottom, 12)
        .accessibilityHidden(true)

      if let title {
        Text(title)
          .font(.title.weight(.semibold))
          .multilineTextAlignment(.center)
          .accessibilityAddTraits(.isHeader)
      }

      if let subtitle {
        Text(subtitle)
          .font(.body.weight(.light))
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }
    }
  }
}
