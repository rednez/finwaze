import Foundation

/// Connection settings of the current build configuration (Debug / Staging / Release).
/// Values come from `ios/Config/<Configuration>.xcconfig` through `ios/Config/Info.plist`.
nonisolated struct SupabaseConfig: Sendable {
    let url: URL
    let publishableKey: String
    /// The web client of the same environment; `nil` when not configured.
    let webAppURL: URL?
    /// The iOS OAuth client for Sign in with Google; `nil` hides the Google button.
    let googleClientID: String?

    static func load(from bundle: Bundle = .main) -> SupabaseConfig {
        guard
            let urlString = bundle.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let url = URL(string: urlString),
            let key = bundle.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String,
            !key.isEmpty
        else {
            fatalError("Missing SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY — check ios/Config/*.xcconfig")
        }
        return SupabaseConfig(
            url: url,
            publishableKey: key,
            webAppURL: optionalString("WEB_APP_URL", in: bundle).flatMap(URL.init(string:)),
            googleClientID: optionalString("GOOGLE_IOS_CLIENT_ID", in: bundle)
        )
    }

    /// An optional setting: `nil` when it is missing or left empty in the xcconfig.
    private static func optionalString(_ key: String, in bundle: Bundle) -> String? {
        (bundle.object(forInfoDictionaryKey: key) as? String).flatMap { $0.isEmpty ? nil : $0 }
    }
}
