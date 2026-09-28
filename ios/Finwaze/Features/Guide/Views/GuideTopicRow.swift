import SwiftUI

/// An article in the guide's list: the section's icon in the topic's colour, the article's name and what it covers.
struct GuideTopicRow: View {
    let topic: GuideTopic

    var body: some View {
        HStack(spacing: 14) {
            GuideTopicIcon(topic: topic)
            VStack(alignment: .leading, spacing: 2) {
                Text(topic.cardTitle)
                    .font(.body.weight(.semibold))
                Text(topic.cardSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}

/// The section's icon on a tint of the topic's colour; decorative, as the title next to it names the article.
struct GuideTopicIcon: View {
    let topic: GuideTopic
    var textStyle: Font.TextStyle = .body
    @ScaledMetric private var size: CGFloat

    init(topic: GuideTopic, textStyle: Font.TextStyle = .body, size: CGFloat = 36) {
        self.topic = topic
        self.textStyle = textStyle
        _size = ScaledMetric(wrappedValue: size, relativeTo: textStyle)
    }

    var body: some View {
        Image(systemName: topic.section.systemImage)
            .font(.system(textStyle).weight(.medium))
            .foregroundStyle(topic.color)
            .frame(width: size, height: size)
            .background(topic.color.opacity(0.15), in: .rect(cornerRadius: size / 4))
            .accessibilityHidden(true)
    }
}

#Preview {
    List(GuideTopic.allCases) { topic in
        GuideTopicRow(topic: topic)
    }
}
