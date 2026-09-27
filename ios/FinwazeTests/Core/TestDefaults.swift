import Foundation

/// A throwaway `UserDefaults` suite, so tests never touch the app's real settings.
func makeTestDefaults() -> UserDefaults {
    let name = "FinwazeTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defaults.removePersistentDomain(forName: name)
    return defaults
}
