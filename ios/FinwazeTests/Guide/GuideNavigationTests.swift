import Testing
@testable import Finwaze

@MainActor
struct GuideNavigationTests {
    @Test func guideOpensOnAllArticles() {
        #expect(GuideNavigation().path.isEmpty)
    }

    @Test func sectionArticleOpensOnTopOfAllArticles() {
        #expect(GuideNavigation(initialTopic: GuideTopic(section: .budget)).path == [.budget])
    }

    @Test func nextThenBackLeadsToAllArticles() {
        var navigation = GuideNavigation(initialTopic: .dashboard)

        navigation.show(.transactions)
        navigation.show(.groups)
        #expect(navigation.path == [.groups])

        navigation.path.removeLast()
        #expect(navigation.path.isEmpty)
    }

    @Test func walkingForwardVisitsEveryArticleInTurn() {
        var navigation = GuideNavigation(initialTopic: .dashboard)
        var visited: [GuideTopic] = [.dashboard]

        while let next = navigation.path.last?.next {
            navigation.show(next)
            visited.append(next)
            #expect(navigation.path.count == 1)
        }

        #expect(visited == GuideTopic.allCases)
    }

    @Test(arguments: GuideTopic.allCases)
    func allGuidesLeadsBackFromAnyArticle(topic: GuideTopic) {
        var navigation = GuideNavigation(initialTopic: topic)

        navigation.showAll()

        #expect(navigation.path.isEmpty)
    }

    @Test func showOnAllArticlesOpensTheArticle() {
        var navigation = GuideNavigation()

        navigation.show(.wallet)

        #expect(navigation.path == [.wallet])
    }
}
