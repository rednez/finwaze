import SwiftUI

/// The guide's first screen (`GUIDE-01`): the intro, "What to do right after signing up" and a row per article.
struct GuideHubView: View {
    var body: some View {
        List {
            Section {
                GuideHubIntro()
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4))
            }

            Section {
                GuideQuickStart(steps: GuideHub.quickStartSteps)
            } header: {
                Text(GuideHub.quickStartTitle)
            }

            Section {
                ForEach(GuideTopic.allCases) { topic in
                    NavigationLink(value: topic) {
                        GuideTopicRow(topic: topic)
                    }
                }
            } header: {
                Text(GuideHub.topicsTitle)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("profile.guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct GuideHubIntro: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(GuideHub.eyebrow)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.tint)
            Text(GuideHub.title)
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)
            Text(GuideHub.lead)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    NavigationStack {
        GuideHubView()
    }
}
