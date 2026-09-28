import SwiftUI

/// "What to do right after signing up": a row per step with its number in a circle, read by VoiceOver as
/// "Step 1 of 4, …".
struct GuideQuickStart: View {
    let steps: [LocalizedStringResource]

    var body: some View {
        ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
            GuideQuickStartStep(number: index + 1, count: steps.count, text: step)
        }
    }
}

private struct GuideQuickStartStep: View {
    let number: Int
    let count: Int
    let text: LocalizedStringResource
    @ScaledMetric(relativeTo: .subheadline) private var badgeSize = 28

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(number, format: .number)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: badgeSize, height: badgeSize)
                .background(.tint, in: .circle)
                .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + 5 }
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("guide.quickStart.step.accessibility \(number) \(count) \(String(localized: text))"))
    }
}

#Preview {
    List {
        GuideQuickStart(steps: GuideHub.quickStartSteps)
    }
}
