import SwiftUI

/// The "More" tab's first screen: the secondary sections and the guide, each opened in this tab (`NAV-02`,
/// `NAV-03`).
struct MoreView: View {
    @Environment(MainNavigation.self) private var navigation

    var body: some View {
        List {
            Section {
                ForEach(AppSection.secondary, id: \.self) { section in
                    NavigationLink(value: section) {
                        Label(section.title, systemImage: section.systemImage)
                    }
                }
            }

            Section {
                NavigationLink(value: GuideRoute()) {
                    Label("profile.guide", systemImage: "book")
                }
            }
        }
        .navigationTitle("section.more")
        .sectionToolbar(for: nil)
        .navigationDestination(for: GuideRoute.self) { _ in
            GuideHubView()
        }
        .navigationDestination(for: GuideTopic.self) { topic in
            GuideArticleView(
                topic: topic,
                onShow: { navigation.showGuideArticle($0) },
                onShowAll: { navigation.showAllGuides() }
            )
        }
    }
}

/// The guide's first screen in the "More" tab's stack; its articles are pushed on top of it as `GuideTopic`s.
struct GuideRoute: Hashable {}

#Preview {
    NavigationStack {
        MoreView()
    }
    .environment(AppViewModel.preview)
    .environment(MainNavigation())
}
