import Observation

/// The selected tab of the main app (`NAV-01`), in the environment so a screen can switch it — e.g. a Dashboard
/// card opening Transactions.
@Observable
final class MainNavigation {
    var selection: AppSection = .dashboard

    /// Switches to a primary section; secondary ones are pushed by their section instead (`NAV-02`).
    func open(_ section: AppSection) {
        guard AppSection.primary.contains(section) else { return }
        selection = section
    }
}
