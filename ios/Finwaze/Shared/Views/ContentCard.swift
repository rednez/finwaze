import SwiftUI

/// A card's link in its header, e.g. "All transactions".
struct ContentCardAction {
    let title: LocalizedStringKey
    let perform: () -> Void
}

/// How much a card stands out on its screen.
enum ContentCardStyle {
    /// Most cards: the grouped background.
    case plain
    /// The screen's headline card, e.g. the Dashboard's balance: a soft wash of the brand colours.
    case prominent
}

/// A card of the Dashboard or Budget: a title — with a small tinted icon when given — an optional explanation, the
/// card's current choice (e.g. "September 2026 · USD") with its settings button, the content and, at its foot, the
/// link to the whole list.
struct ContentCard<Content: View, Accessory: View>: View {
    typealias Action = ContentCardAction

    let title: Text
    var subtitle: Text?
    var action: Action?
    var systemImage: String?
    var tint: Color
    var style: ContentCardStyle
    /// A small control at the header's end, e.g. a chart's settings menu.
    let accessory: Accessory
    @ViewBuilder let content: Content

    /// A card whose subtitle is its current choice and whose header ends with `accessory`.
    init(
        title: LocalizedStringKey,
        detail: Text?,
        action: Action? = nil,
        systemImage: String? = nil,
        tint: Color = .accentColor,
        @ViewBuilder accessory: () -> Accessory,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            title: Text(title), subtitle: detail, action: action, systemImage: systemImage, tint: tint, style: .plain,
            accessory: accessory(), content: content
        )
    }

    fileprivate init(
        title: Text,
        subtitle: Text?,
        action: Action?,
        systemImage: String?,
        tint: Color,
        style: ContentCardStyle,
        accessory: Accessory,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.systemImage = systemImage
        self.tint = tint
        self.style = style
        self.accessory = accessory
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                if let systemImage {
                    TintedIcon(systemImage: systemImage, tint: tint)
                }
                VStack(alignment: .leading, spacing: 1) {
                    title
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    if let subtitle {
                        subtitle
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 8)
                accessory
            }
            content
            if let action {
                CardFooterLink(action: action)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background { CardBackground(style: style) }
    }
}

extension ContentCard where Accessory == EmptyView {
    init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        action: Action? = nil,
        systemImage: String? = nil,
        tint: Color = .accentColor,
        style: ContentCardStyle = .plain,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            title: Text(title), subtitle: subtitle.map { Text($0) }, action: action, systemImage: systemImage,
            tint: tint, style: style, accessory: EmptyView(), content: content
        )
    }

    /// A card titled with the user's own words, e.g. a group's name, which is never looked up in the catalog.
    init(
        verbatim title: String,
        subtitle: LocalizedStringKey? = nil,
        action: Action? = nil,
        systemImage: String? = nil,
        tint: Color = .accentColor,
        style: ContentCardStyle = .plain,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            title: Text(verbatim: title), subtitle: subtitle.map { Text($0) }, action: action,
            systemImage: systemImage, tint: tint, style: style, accessory: EmptyView(), content: content
        )
    }
}

/// "All transactions ›" across a card's foot, under a hairline: the way on to the whole list.
private struct CardFooterLink: View {
    let action: ContentCardAction

    var body: some View {
        VStack(spacing: 10) {
            Divider()
            Button(action: action.perform) {
                HStack {
                    Text(action.title)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .font(.subheadline.weight(.medium))
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)
        }
    }
}

/// The grouped background of a card, or for a prominent one the brand's soft wash over it.
struct CardBackground: View {
    var style: ContentCardStyle = .plain

    static let cornerRadius: CGFloat = 26
    static let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

    var body: some View {
        Self.shape
            .fill(Color(.secondarySystemGroupedBackground))
            .overlay {
                if style == .prominent {
                    Self.shape.fill(
                        LinearGradient(
                            colors: [.brandGradientStart.opacity(0.16), .brandGradientEnd.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    Self.shape.strokeBorder(.brandGradientStart.opacity(0.12))
                }
            }
    }
}

/// A small SF Symbol on a soft tint of its colour, the badge of a card's title or a total.
struct TintedIcon: View {
    let systemImage: String
    var tint: Color = .accentColor
    @ScaledMetric(relativeTo: .headline) private var size: CGFloat = 28

    var body: some View {
        Image(systemName: systemImage)
            .font(.footnote.weight(.bold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.15), in: .rect(cornerRadius: size * 0.32, style: .continuous))
            .accessibilityHidden(true)
    }
}

/// A card's content by its state (`DASH-08`): a skeleton while loading (`GEN-23`), a short error with "Try again"
/// that reloads only this card (`GEN-25`), or the content.
///
/// The skeleton and the content are one view whose data and redaction change, never two branches: a chart is not
/// rebuilt on every new filter, so its marks move from the old figures to the new ones instead of blinking. While
/// another key loads, the skeleton keeps the last figures — hidden under the redaction — rather than jumping to
/// `placeholder`, which is only shown before the first load.
struct CardStateView<Value: Equatable & Sendable, Content: View>: View {
    let state: CardState<Value>
    let placeholder: Value
    let onRetry: () -> Void
    @ViewBuilder let content: (Value) -> Content
    /// The figures shown last, kept under the skeleton while the next ones load.
    @State private var lastValue: Value?

    var body: some View {
        if case .failed = state {
            CardErrorView(onRetry: onRetry)
        } else {
            let isLoading = state == .loading
            content(state.value ?? lastValue ?? placeholder)
                .redacted(reason: isLoading ? .placeholder : [])
                .allowsHitTesting(!isLoading)
                .accessibilityHidden(isLoading)
                .overlay {
                    if isLoading {
                        Color.clear
                            .accessibilityElement()
                            .accessibilityLabel(Text("common.loading"))
                    }
                }
                .animation(.smooth, value: state)
                .onChange(of: state.value, initial: true) { _, value in
                    if let value {
                        lastValue = value
                    }
                }
        }
    }
}

/// A card's short error with "Try again" that reloads only this card (`GEN-25`).
struct CardErrorView: View {
    let onRetry: () -> Void

    var body: some View {
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

/// A whole screen's error with "Try again" (`GEN-25`); `actions` adds buttons below it.
struct ScreenErrorView<Actions: View>: View {
    let onRetry: () -> Void
    @ViewBuilder var actions: Actions

    var body: some View {
        ContentUnavailableView {
            Label("error.generic.title", systemImage: "exclamationmark.triangle")
        } description: {
            Text("error.generic.message")
        } actions: {
            Button("common.retry", systemImage: "arrow.clockwise", action: onRetry)
                .buttonStyle(.glassProminent)
            actions
        }
    }
}

extension ScreenErrorView where Actions == EmptyView {
    init(onRetry: @escaping () -> Void) {
        self.init(onRetry: onRetry) { EmptyView() }
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
