import Foundation

/// Remembers on the device that the app is in demo mode, so a relaunch stays in it (`AUTH-10`, `AUTH-12`).
final class DemoModeStorage {
    private static let key = "demoMode.isEnabled"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isEnabled: Bool {
        get { defaults.bool(forKey: Self.key) }
        set { defaults.set(newValue, forKey: Self.key) }
    }
}
