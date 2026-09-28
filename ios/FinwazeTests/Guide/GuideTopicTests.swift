import Foundation
import Testing
@testable import Finwaze

@MainActor
struct GuideTopicTests {
    @Test func followsTheWebOrder() {
        #expect(GuideTopic.allCases == [.dashboard, .transactions, .groups, .wallet, .budget, .goals, .analytics])
    }

    @Test func everySectionHasItsArticle() {
        for section in AppSection.allCases {
            #expect(GuideTopic(section: section).section == section)
        }
        for topic in GuideTopic.allCases {
            #expect(GuideTopic(section: topic.section) == topic)
        }
    }

    @Test func firstHasNoPreviousAndLastNoNext() {
        #expect(GuideTopic.dashboard.previous == nil)
        #expect(GuideTopic.analytics.next == nil)
    }

    @Test func neighboursPointAtEachOther() {
        let topics = GuideTopic.allCases
        for (topic, next) in zip(topics, topics.dropFirst()) {
            #expect(topic.next == next)
            #expect(next.previous == topic)
        }
    }

    @Test func everyArticleHasThreeToFourSectionsAndTips() {
        for topic in GuideTopic.allCases {
            #expect((3...4).contains(topic.sections.count), "\(topic)")
            #expect(!topic.tips.isEmpty, "\(topic)")
        }
    }

    @Test func quickStartHasFourSteps() {
        #expect(GuideHub.quickStartSteps.count == 4)
    }

    @Test func keysAreUnique() {
        let keys = Self.modelKeys
        #expect(Set(keys).count == keys.count)
    }

    @Test(arguments: ["en", "uk", "cs"])
    func everyKeyIsTranslated(language: String) throws {
        let path = try #require(Bundle.main.path(forResource: language, ofType: "lproj"))
        let bundle = try #require(Bundle(path: path))
        let missing = "\u{0}missing"

        for key in Self.modelKeys + Self.viewKeys {
            let value = bundle.localizedString(forKey: key, value: missing, table: nil)
            #expect(value != missing && value != key && !value.isEmpty, "\(key) in \(language)")
        }
    }

    /// Every text of the model: the hub and each article.
    private static var modelKeys: [String] {
        var resources = [
            GuideHub.eyebrow, GuideHub.title, GuideHub.lead, GuideHub.quickStartTitle, GuideHub.topicsTitle,
        ] + GuideHub.quickStartSteps
        for topic in GuideTopic.allCases {
            resources += [topic.cardTitle, topic.cardSummary, topic.eyebrow, topic.title, topic.lead]
            resources += topic.sections.flatMap { [$0.heading, $0.body] }
            resources += topic.tips
        }
        return resources.map(\.key)
    }

    /// The guide's own labels in its views.
    private static let viewKeys = [
        "guide.tipsLabel",
        "guide.backToGuide",
        "guide.previous",
        "guide.next",
        "guide.previous.accessibility %@",
        "guide.next.accessibility %@",
        "guide.quickStart.step.accessibility %lld %lld %@",
    ]
}
