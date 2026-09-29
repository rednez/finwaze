import SwiftUI

/// A screen of one record: a spinner while it loads (`GEN-23`), "not found" with a way back, an error with "Try
/// again" (`GEN-25`), then `content`.
struct DetailStateView<Value, Content: View>: View {
    /// Texts of the "not found" state.
    struct NotFound {
        let title: LocalizedStringKey
        let message: LocalizedStringKey
        let back: LocalizedStringKey
    }

    let state: DetailState<Value>
    let notFound: NotFound
    let onRetry: () -> Void
    @ViewBuilder let content: (Value) -> Content
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        switch state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
        case .notFound:
            ContentUnavailableView {
                Label(notFound.title, systemImage: "questionmark.circle")
            } description: {
                Text(notFound.message)
            } actions: {
                Button(notFound.back) { dismiss() }
                    .buttonStyle(.glassProminent)
            }
        case .failed:
            ScreenErrorView(onRetry: onRetry)
        case .loaded(let value):
            content(value)
        }
    }
}
