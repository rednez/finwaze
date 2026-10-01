import SwiftUI

/// Top-level sections of the signed-in app (`NAV-01`, `NAV-02`).
enum AppSection: String, Hashable, CaseIterable {
    case dashboard, transactions, wallet, budget
    case goals, groups, analytics

    /// Always in the tab bar (`NAV-01`).
    static let primary: [AppSection] = [.dashboard, .transactions, .wallet, .budget]
    /// In the "More" tab, not in the tab bar (`NAV-02`).
    static let secondary: [AppSection] = [.goals, .groups, .analytics]

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

    /// The section's "+" action, shown next to "?", or `nil` when it has none.
    var addTitle: LocalizedStringKey? {
        switch self {
        case .transactions: "transactions.add"
        case .wallet: "wallet.addAccount"
        case .groups: "groups.addGroup"
        case .goals: "goals.add"
        default: nil
        }
    }

    /// The section's "Transfer money" action, shown before "+", or `nil` when it has none (`ACC-01`).
    var transferTitle: LocalizedStringKey? {
        switch self {
        case .wallet: "wallet.transferMoney"
        default: nil
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "square.grid.2x2"
        case .transactions: "list.bullet.circle"
        case .wallet: "wallet.bifold"
        case .budget: "chart.pie"
        case .goals: "target"
        case .groups: "folder"
        case .analytics: "chart.bar.xaxis"
        }
    }
}
