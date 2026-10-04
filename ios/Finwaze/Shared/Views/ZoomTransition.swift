import SwiftUI

extension EnvironmentValues {
    /// The namespace of a tab's navigation stack, in which a card and the screen it opens share a zoom transition.
    @Entry var zoomNamespace: Namespace.ID?
}

extension View {
    /// The card or row a screen zooms out of, like a photo opening in Photos (iOS 18 zoom transition). Does nothing
    /// outside a tab's stack. `cornerRadius` is the source's own: a card's by default, a smaller one for a row inside
    /// a card.
    func zoomSource(_ id: String, cornerRadius: CGFloat = CardBackground.cornerRadius) -> some View {
        modifier(ZoomSource(id: id, cornerRadius: cornerRadius))
    }

    /// The screen that zooms out of `zoomSource(id)`; the usual push without a namespace.
    @ViewBuilder
    func zoomDestination(_ id: String, in namespace: Namespace.ID?) -> some View {
        if let namespace {
            navigationTransition(.zoom(sourceID: id, in: namespace))
        } else {
            self
        }
    }
}

private struct ZoomSource: ViewModifier {
    let id: String
    let cornerRadius: CGFloat
    @Environment(\.zoomNamespace) private var namespace

    func body(content: Content) -> some View {
        if let namespace {
            // The source's own background and shape: a row has none of its own, as its card draws them, so without
            // them the zoom would grow a transparent, square snapshot.
            content.matchedTransitionSource(id: id, in: namespace) { source in
                source
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            }
        } else {
            content
        }
    }
}

/// The zoom sources' ids, one per kind of screen, so a transaction and an account with the same number never meet.
enum ZoomID {
    static func transaction(_ id: Int64) -> String { "transaction-\(id)" }
    static func transfer(_ id: Int64) -> String { "transfer-\(id)" }
    static func account(_ id: Int64) -> String { "account-\(id)" }
    static func goal(_ id: Int64) -> String { "goal-\(id)" }
    static func budgetGroup(_ id: Int64) -> String { "budget-group-\(id)" }
}
