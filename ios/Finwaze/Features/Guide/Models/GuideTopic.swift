import SwiftUI

/// A guide article, one per section (`GUIDE-02`), in the web's order (`src/app/features/guide/guide-topics.ts`),
/// which also sets the previous and next article.
enum GuideTopic: String, CaseIterable, Hashable, Identifiable {
    case dashboard, transactions, groups, wallet, budget, goals, analytics

    var id: Self { self }

    /// The article about `section`, opened by "Learn about this section" (`GUIDE-03`).
    init(section: AppSection) {
        self = switch section {
        case .dashboard: .dashboard
        case .transactions: .transactions
        case .groups: .groups
        case .wallet: .wallet
        case .budget: .budget
        case .goals: .goals
        case .analytics: .analytics
        }
    }

    var section: AppSection {
        switch self {
        case .dashboard: .dashboard
        case .transactions: .transactions
        case .groups: .groups
        case .wallet: .wallet
        case .budget: .budget
        case .goals: .goals
        case .analytics: .analytics
        }
    }

    var previous: GuideTopic? {
        neighbour(by: -1)
    }

    var next: GuideTopic? {
        neighbour(by: 1)
    }

    private func neighbour(by offset: Int) -> GuideTopic? {
        let all = Self.allCases
        guard let index = all.firstIndex(of: self) else { return nil }
        let neighbour = index + offset
        return all.indices.contains(neighbour) ? all[neighbour] : nil
    }

    /// The article's accent, the web's colour for the topic, readable in both appearances.
    var color: Color {
        switch self {
        case .dashboard: .guideIndigo
        case .transactions: .guideEmerald
        case .groups: .guideAmber
        case .wallet: .guideViolet
        case .budget: .guideSky
        case .goals: .guideRose
        case .analytics: .guideFuchsia
        }
    }

    // Literal keys, not `"guide.\(rawValue).title"`: an interpolated key becomes the format "guide.%@.title" and never
    // matches the catalog.

    /// The article's name in the list of articles and the article navigation.
    var cardTitle: LocalizedStringResource {
        switch self {
        case .dashboard: "guide.dashboard.cardTitle"
        case .transactions: "guide.transactions.cardTitle"
        case .groups: "guide.groups.cardTitle"
        case .wallet: "guide.wallet.cardTitle"
        case .budget: "guide.budget.cardTitle"
        case .goals: "guide.goals.cardTitle"
        case .analytics: "guide.analytics.cardTitle"
        }
    }

    var cardSummary: LocalizedStringResource {
        switch self {
        case .dashboard: "guide.dashboard.cardSummary"
        case .transactions: "guide.transactions.cardSummary"
        case .groups: "guide.groups.cardSummary"
        case .wallet: "guide.wallet.cardSummary"
        case .budget: "guide.budget.cardSummary"
        case .goals: "guide.goals.cardSummary"
        case .analytics: "guide.analytics.cardSummary"
        }
    }

    var eyebrow: LocalizedStringResource {
        switch self {
        case .dashboard: "guide.dashboard.eyebrow"
        case .transactions: "guide.transactions.eyebrow"
        case .groups: "guide.groups.eyebrow"
        case .wallet: "guide.wallet.eyebrow"
        case .budget: "guide.budget.eyebrow"
        case .goals: "guide.goals.eyebrow"
        case .analytics: "guide.analytics.eyebrow"
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .dashboard: "guide.dashboard.title"
        case .transactions: "guide.transactions.title"
        case .groups: "guide.groups.title"
        case .wallet: "guide.wallet.title"
        case .budget: "guide.budget.title"
        case .goals: "guide.goals.title"
        case .analytics: "guide.analytics.title"
        }
    }

    var lead: LocalizedStringResource {
        switch self {
        case .dashboard: "guide.dashboard.lead"
        case .transactions: "guide.transactions.lead"
        case .groups: "guide.groups.lead"
        case .wallet: "guide.wallet.lead"
        case .budget: "guide.budget.lead"
        case .goals: "guide.goals.lead"
        case .analytics: "guide.analytics.lead"
        }
    }

    var sections: [GuideSection] {
        switch self {
        case .dashboard: [
            GuideSection(heading: "guide.dashboard.section1.heading", body: "guide.dashboard.section1.body"),
            GuideSection(heading: "guide.dashboard.section2.heading", body: "guide.dashboard.section2.body"),
            GuideSection(heading: "guide.dashboard.section3.heading", body: "guide.dashboard.section3.body"),
        ]
        case .transactions: [
            GuideSection(heading: "guide.transactions.section1.heading", body: "guide.transactions.section1.body"),
            GuideSection(heading: "guide.transactions.section2.heading", body: "guide.transactions.section2.body"),
            GuideSection(heading: "guide.transactions.section3.heading", body: "guide.transactions.section3.body"),
            GuideSection(heading: "guide.transactions.section4.heading", body: "guide.transactions.section4.body"),
        ]
        case .groups: [
            GuideSection(heading: "guide.groups.section1.heading", body: "guide.groups.section1.body"),
            GuideSection(heading: "guide.groups.section2.heading", body: "guide.groups.section2.body"),
            GuideSection(heading: "guide.groups.section3.heading", body: "guide.groups.section3.body"),
        ]
        case .wallet: [
            GuideSection(heading: "guide.wallet.section1.heading", body: "guide.wallet.section1.body"),
            GuideSection(heading: "guide.wallet.section2.heading", body: "guide.wallet.section2.body"),
            GuideSection(heading: "guide.wallet.section3.heading", body: "guide.wallet.section3.body"),
        ]
        case .budget: [
            GuideSection(heading: "guide.budget.section1.heading", body: "guide.budget.section1.body"),
            GuideSection(heading: "guide.budget.section2.heading", body: "guide.budget.section2.body"),
            GuideSection(heading: "guide.budget.section3.heading", body: "guide.budget.section3.body"),
        ]
        case .goals: [
            GuideSection(heading: "guide.goals.section1.heading", body: "guide.goals.section1.body"),
            GuideSection(heading: "guide.goals.section2.heading", body: "guide.goals.section2.body"),
            GuideSection(heading: "guide.goals.section3.heading", body: "guide.goals.section3.body"),
        ]
        case .analytics: [
            GuideSection(heading: "guide.analytics.section1.heading", body: "guide.analytics.section1.body"),
            GuideSection(heading: "guide.analytics.section2.heading", body: "guide.analytics.section2.body"),
            GuideSection(heading: "guide.analytics.section3.heading", body: "guide.analytics.section3.body"),
        ]
        }
    }

    /// "Best practices".
    var tips: [LocalizedStringResource] {
        switch self {
        case .dashboard: ["guide.dashboard.tip1", "guide.dashboard.tip2", "guide.dashboard.tip3"]
        case .transactions: [
            "guide.transactions.tip1", "guide.transactions.tip2", "guide.transactions.tip3", "guide.transactions.tip4",
        ]
        case .groups: ["guide.groups.tip1", "guide.groups.tip2", "guide.groups.tip3", "guide.groups.tip4"]
        case .wallet: [
            "guide.wallet.tip1", "guide.wallet.tip2", "guide.wallet.tip3", "guide.wallet.tip4", "guide.wallet.tip5",
        ]
        case .budget: [
            "guide.budget.tip1", "guide.budget.tip2", "guide.budget.tip3", "guide.budget.tip4", "guide.budget.tip5",
        ]
        case .goals: ["guide.goals.tip1", "guide.goals.tip2", "guide.goals.tip3", "guide.goals.tip4"]
        case .analytics: ["guide.analytics.tip1", "guide.analytics.tip2", "guide.analytics.tip3", "guide.analytics.tip4"]
        }
    }
}
