import SwiftUI

/// The foot of an article: the previous and next articles by name — side by side, or one under the other when they
/// do not fit, e.g. at the largest text sizes — and "All guides". The first article has no previous one, the last
/// no next one.
struct GuideArticleNav: View {
    let topic: GuideTopic
    let onShow: (GuideTopic) -> Void
    let onShowAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 12) {
                    previousButton(fillsWidth: false)
                    Spacer(minLength: 0)
                    nextButton(fillsWidth: false)
                }
                VStack(spacing: 12) {
                    previousButton(fillsWidth: true)
                    nextButton(fillsWidth: true)
                }
            }

            Button("guide.backToGuide", systemImage: "list.bullet", action: onShowAll)
                .font(.body.weight(.medium))
        }
    }

    @ViewBuilder
    private func previousButton(fillsWidth: Bool) -> some View {
        if let previous = topic.previous {
            NeighbourButton(
                topic: previous,
                caption: "guide.previous",
                systemImage: "chevron.left",
                accessibilityLabel: Text("guide.previous.accessibility \(String(localized: previous.cardTitle))"),
                alignment: .leading,
                fillsWidth: fillsWidth
            ) { onShow(previous) }
        }
    }

    @ViewBuilder
    private func nextButton(fillsWidth: Bool) -> some View {
        if let next = topic.next {
            NeighbourButton(
                topic: next,
                caption: "guide.next",
                systemImage: "chevron.right",
                accessibilityLabel: Text("guide.next.accessibility \(String(localized: next.cardTitle))"),
                alignment: .trailing,
                fillsWidth: fillsWidth
            ) { onShow(next) }
        }
    }
}

private struct NeighbourButton: View {
    let topic: GuideTopic
    let caption: LocalizedStringKey
    let systemImage: String
    let accessibilityLabel: Text
    let alignment: HorizontalAlignment
    /// One under the other, each spans the width, the next article at its trailing edge.
    let fillsWidth: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if alignment == .leading { chevron }
                VStack(alignment: alignment, spacing: 2) {
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(topic.cardTitle)
                        .font(.subheadline.weight(.semibold))
                        .multilineTextAlignment(alignment == .leading ? .leading : .trailing)
                }
                if alignment == .trailing { chevron }
            }
            .padding(.vertical, 4)
            .frame(maxWidth: fillsWidth ? .infinity : nil, alignment: alignment == .leading ? .leading : .trailing)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 14))
        .accessibilityLabel(accessibilityLabel)
    }

    private var chevron: some View {
        Image(systemName: systemImage)
            .font(.footnote.weight(.semibold))
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
