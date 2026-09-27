import Foundation

/// Connection settings of the current build configuration (Debug / Staging / Release).
/// Values come from `ios/Config/<Configuration>.xcconfig` through `ios/Config/Info.plist`.
nonisolated struct SupabaseConfig: Sendable {
    let url: URL
    let publishableKey: String
    /// The web client of the same environment; `nil` when not configured.
    let webAppURL: URL?

    static func load(from bundle: Bundle = .main) -> SupabaseConfig {
        guard
            let urlString = bundle.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let url = URL(string: urlString),
            let key = bundle.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String,
            !key.isEmpty
        else {
            fatalError("Missing SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY — check ios/Config/*.xcconfig")
        }
        let webAppURL = (bundle.object(forInfoDictionaryKey: "WEB_APP_URL") as? String)
            .flatMap { $0.isEmpty ? nil : URL(string: $0) }
        return SupabaseConfig(url: url, publishableKey: key, webAppURL: webAppURL)
    }
}
