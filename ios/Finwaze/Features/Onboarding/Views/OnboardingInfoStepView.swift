import SwiftUI

/// An informational page: eyebrow, title, description, three benefits and an illustration (`ONB-01`).
struct OnboardingInfoStepView: View {
    let step: OnboardingInfoStep

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(step.image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 24))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24).strokeBorder(.separator.opacity(0.5))
                    }
                    .shadow(color: .brandGradientStart.opacity(0.12), radius: 16, y: 6)
                    .accessibilityHidden(true)

                OnboardingHeading(eyebrow: step.eyebrow, title: step.title, description: step.description)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(step.bullets.indices, id: \.self) { index in
                        Label {
                            Text(step.bullets[index])
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.tint)
                        }
                        .font(.subheadline)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
    }
}

/// Eyebrow, title and description at the top of every onboarding step.
struct OnboardingHeading: View {
    let eyebrow: LocalizedStringResource
    let title: LocalizedStringResource
    let description: LocalizedStringResource

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(eyebrow)
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(.tint)
            Text(title)
                .font(.title.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
            Text(description)
                .font(.body.weight(.light))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    OnboardingInfoStepView(step: OnboardingInfoStep.all[0])
}
