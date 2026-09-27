import SwiftUI

/// Top-level sections of the signed-in app (`NAV-01`, `NAV-02`).
enum AppSection: String, Hashable, CaseIterable {
    case dashboard, transactions, wallet, budget, goals
    case groups, analytics

    /// Always in the tab bar (`NAV-01`).
    static let primary: [AppSection] = [.dashboard, .transactions, .wallet, .budget, .goals]
    /// Reachable from the "More" menu of any section, not from the tab bar (`NAV-02`).
    static let secondary: [AppSection] = [.groups, .analytics]

    /// Short label for the tab bar or sidebar.
    var tabTitle: LocalizedStringKey {
        switch self {
        case .groups: "section.groups.tab"
        default: title
        }
    }

    // Literal keys, not `"section.\(rawValue).title"`: an interpolated `LocalizedStringKey`
    // becomes the format "section.%@.title" and never matches the catalog.
    var title: LocalizedStringKey {
        switch self {
        case .dashboard: "section.dashboard.title"
        case .transactions: "section.transactions.title"
        case .wallet: "section.wallet.title"
        case .budget: "section.budget.title"
        case .goals: "section.goals.title"
        case .groups: "section.groups.title"
        case .analytics: "section.analytics.title"
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .dashboard: "section.dashboard.description"
        case .transactions: "section.transactions.description"
        case .wallet: "section.wallet.description"
        case .budget: "section.budget.description"
        case .goals: "section.goals.description"
        case .groups: "section.groups.description"
        case .analytics: "section.analytics.description"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "square.grid.2x2"
        case .transactions: "arrow.left.arrow.right"
        case .wallet: "wallet.bifold"
        case .budget: "chart.pie"
        case .goals: "target"
        case .groups: "folder"
        case .analytics: "chart.bar.xaxis"
        }
    }
}
