import SwiftUI

/// A guide article (`GUIDE-02`): the section's icon, the eyebrow, the title and the intro, the sections, "Best
/// practices" and the way to the neighbouring articles or back to all of them. The text keeps a readable width in
/// landscape.
struct GuideArticleView: View {
    let topic: GuideTopic
    let onShow: (GuideTopic) -> Void
    let onShowAll: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                GuideArticleHeader(topic: topic)

                ForEach(topic.sections, id: \.heading.key) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.heading)
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        Text(section.body)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }

                GuideTipsCard(tips: topic.tips, color: topic.color)

                GuideArticleNav(topic: topic, onShow: onShow, onShowAll: onShowAll)
            }
            .frame(maxWidth: 680, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(Text(topic.title))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct GuideArticleHeader: View {
    let topic: GuideTopic

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GuideTopicIcon(topic: topic, textStyle: .title2, size: 48)
                .padding(.bottom, 4)
            Text(topic.eyebrow)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(topic.color)
            Text(topic.title)
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)
            Text(topic.lead)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    NavigationStack {
        GuideArticleView(topic: .transactions, onShow: { _ in }, onShowAll: {})
    }
}
