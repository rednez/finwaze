import Foundation

/// The texts of the guide's first screen (`GUIDE-01`): the intro, the quick start and the title of the articles.
enum GuideHub {
    static let eyebrow: LocalizedStringResource = "guide.hub.eyebrow"
    static let title: LocalizedStringResource = "guide.hub.title"
    static let lead: LocalizedStringResource = "guide.hub.lead"
    static let quickStartTitle: LocalizedStringResource = "guide.hub.quickStart.title"
    /// "What to do right after signing up", in order.
    static let quickStartSteps: [LocalizedStringResource] = [
        "guide.hub.quickStart.step1",
        "guide.hub.quickStart.step2",
        "guide.hub.quickStart.step3",
        "guide.hub.quickStart.step4",
    ]
    static let topicsTitle: LocalizedStringResource = "guide.hub.topicsTitle"
}
