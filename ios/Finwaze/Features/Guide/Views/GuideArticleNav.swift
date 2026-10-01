import SwiftUI

/// The foot of an article, as one grouped list like Settings: the previous and the next article — each with its
/// section's icon, "Previous" or "Next" over its name — and "All guides". The first article has no previous one, the
/// last no next one.
struct GuideArticleNav: View {
    let topic: GuideTopic
    let onShow: (GuideTopic) -> Void
    let onShowAll: () -> Void

    var body: some View {
        FormSection {
            if let previous = topic.previous {
                NeighbourRow(topic: previous, caption: "guide.previous") { onShow(previous) }
                    .accessibilityLabel(Text("guide.previous.accessibility \(String(localized: previous.cardTitle))"))
            }
            if let next = topic.next {
                NeighbourRow(topic: next, caption: "guide.next") { onShow(next) }
                    .accessibilityLabel(Text("guide.next.accessibility \(String(localized: next.cardTitle))"))
            }
            Button(action: onShowAll) {
                HStack(spacing: 12) {
                    FormRowIcon(systemImage: "list.bullet", tint: .gray)
                    Text("guide.backToGuide")
                        .foregroundStyle(.primary)
                    Spacer(minLength: 8)
                    NavigationChevron()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
    }
}

/// A neighbouring article: its icon, "Previous" or "Next" small above its name, and a chevron.
private struct NeighbourRow: View {
    let topic: GuideTopic
    let caption: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                GuideTopicIcon(topic: topic, size: FormRowMetrics.iconSize)
                VStack(alignment: .leading, spacing: 2) {
                    Text(caption)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(topic.cardTitle)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 8)
                NavigationChevron()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

private struct NavigationChevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.tertiary)
            .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: 40) {
        GuideArticleNav(topic: .dashboard, onShow: { _ in }, onShowAll: {})
        GuideArticleNav(topic: .budget, onShow: { _ in }, onShowAll: {})
        GuideArticleNav(topic: .analytics, onShow: { _ in }, onShowAll: {})
    }
    .padding()
}
