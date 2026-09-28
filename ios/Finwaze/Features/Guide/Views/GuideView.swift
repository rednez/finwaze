import SwiftUI

/// The guide (`GUIDE-01…04`) as a sheet: all articles, or `initialTopic`'s article on top of them, so "Back" leads to
/// all articles (`GUIDE-03`). "Done" closes it from any screen.
struct GuideView: View {
    @State private var navigation: GuideNavigation
    @Environment(\.dismiss) private var dismiss

    init(initialTopic: GuideTopic?) {
        _navigation = State(initialValue: GuideNavigation(initialTopic: initialTopic))
    }

    var body: some View {
        NavigationStack(path: $navigation.path) {
            GuideHubView()
                .toolbar { doneButton }
                .navigationDestination(for: GuideTopic.self) { topic in
                    GuideArticleView(
                        topic: topic,
                        onShow: { navigation.show($0) },
                        onShowAll: { navigation.showAll() }
                    )
                    .toolbar { doneButton }
                }
        }
    }

    private var doneButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("common.done", role: .confirm) { dismiss() }
        }
    }
}

#Preview("Guide") {
    GuideView(initialTopic: nil)
}

#Preview("Article") {
    GuideView(initialTopic: .budget)
}
