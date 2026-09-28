import Observation
import SwiftUI

/// The selected tab of the main app (`NAV-01`, `NAV-02`), in the environment so a screen can switch it — e.g. a
/// Dashboard card opening Transactions or Goals.
@Observable
final class MainNavigation {
    var selection: MainTab = .section(.dashboard)
    /// The "More" tab's stack, here so a secondary section can be opened from another tab.
    var morePath = NavigationPath()

    /// Switches to a primary section's tab, or to "More" with the secondary section on top of it.
    func open(_ section: AppSection) {
        if AppSection.primary.contains(section) {
            selection = .section(section)
        } else {
            morePath = NavigationPath([section])
            selection = .more
        }
    }
}
