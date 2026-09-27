import Foundation

extension AppViewModel {
    /// A signed-out app backed by offline repositories, for SwiftUI previews.
    static var preview: AppViewModel {
        let defaults = UserDefaults(suiteName: "preview") ?? .standard
        return AppViewModel(
            authRepository: PreviewAuthRepository(),
            liveRepositories: .demo,
            preferences: DevicePreferences(defaults: defaults),
            demoMode: DemoModeStorage(defaults: defaults)
        )
    }
}
