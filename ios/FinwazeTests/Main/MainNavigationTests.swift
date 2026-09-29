import SwiftUI
import Testing
@testable import Finwaze

@MainActor
struct MainNavigationTests {
    @Test func neighbouringArticleReplacesTheOpenOne() {
        let navigation = MainNavigation()
        navigation.morePath = path(GuideTopic.dashboard)

        navigation.showGuideArticle(.transactions)
        navigation.showGuideArticle(.groups)

        #expect(navigation.morePath == path(GuideTopic.groups))
    }

    @Test(arguments: GuideTopic.allCases)
    func allGuidesLeadsBackFromAnyArticle(topic: GuideTopic) {
        let navigation = MainNavigation()
        navigation.morePath = path(topic)

        navigation.showAllGuides()

        #expect(navigation.morePath == path())
    }

    /// The guide's first screen in "More", with `topic`'s article on top of it.
    private func path(_ topic: GuideTopic? = nil) -> NavigationPath {
        var path = NavigationPath()
        path.append(GuideRoute())
        if let topic { path.append(topic) }
        return path
    }
}
