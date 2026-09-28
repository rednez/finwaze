import SwiftUI

/// A card's link in its header, e.g. "All transactions".
struct ContentCardAction {
    let title: LocalizedStringKey
    let perform: () -> Void
}

/// A card of the Dashboard or Budget: a title, an optional explanation and link, and the content, on the grouped
/// background.
struct ContentCard<Content: View>: View {
    typealias Action = ContentCardAction

    let title: Text
    var subtitle: LocalizedStringKey?
    var action: Action?
    @ViewBuilder let content: Content

    init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        action: Action? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(title: Text(title), subtitle: subtitle, action: action, content: content)
    }

    /// A card titled with the user's own words, e.g. a group's name, which is never looked up in the catalog.
    init(
        verbatim title: String,
        subtitle: LocalizedStringKey? = nil,
        action: Action? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(title: Text(verbatim: title), subtitle: subtitle, action: action, content: content)
    }

    private init(title: Text, subtitle: LocalizedStringKey?, action: Action?, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    title
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    if let subtitle {
                        Text(subtitle)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 8)
                if let action {
                    Button(action.title, action: action.perform)
                        .font(.subheadline)
                }
            }
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
    }
}

/// A card's content by its state (`DASH-08`): a skeleton of `placeholder` while loading (`GEN-23`), a short error
/// with "Try again" that reloads only this card (`GEN-25`), or the content.
struct CardStateView<Value: Equatable & Sendable, Content: View>: View {
    let state: CardState<Value>
    let placeholder: Value
    let onRetry: () -> Void
    @ViewBuilder let content: (Value) -> Content

    var body: some View {
        switch state {
        case .loading:
            content(placeholder)
                .redacted(reason: .placeholder)
                .allowsHitTesting(false)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("common.loading"))
        case .loaded(let value):
            content(value)
        case .failed:
            VStack(alignment: .leading, spacing: 8) {
                Label("error.generic.title", systemImage: "exclamationmark.triangle")
                    .font(.subheadline.weight(.semibold))
                Text("error.generic.message")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button("common.retry", systemImage: "arrow.clockwise", action: onRetry)
                    .buttonStyle(.bordered)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// An empty card (`GEN-24`): what is missing, one sentence and the way to fix it.
struct CardEmptyState: View {
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let actionTitle: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button(actionTitle, action: action)
                .buttonStyle(.bordered)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension Decimal {
    /// For chart marks, which plot `Double`s; the figures shown as text stay `Decimal`.
    var chartValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
