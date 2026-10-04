import SwiftUI

/// A screen of one record: a spinner while it loads (`GEN-23`), "not found" with a way back, an error with "Try
/// again" (`GEN-25`), then `content`, faded in so it does not pop in right after the push.
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
        Group {
            switch state {
            case .loading:
                DelayedProgressView()
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
        .animation(.easeOut(duration: 0.2), value: state.isLoading)
    }
}

/// The grouped background, with a spinner only once loading takes a while: a quick load goes straight from the
/// push to the content, without a spinner flashing in between (HIG, Progress indicators).
private struct DelayedProgressView: View {
    @State private var isShown = false

    var body: some View {
        ZStack {
            if isShown {
                ProgressView()
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .task {
            guard (try? await Task.sleep(for: .milliseconds(500))) != nil else { return }
            withAnimation { isShown = true }
        }
    }
}

private extension DetailState {
    var isLoading: Bool {
        if case .loading = self { true } else { false }
    }
}
