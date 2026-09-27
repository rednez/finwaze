import Foundation

/// Connection settings read from the git-ignored `Config/Supabase.plist`.
/// Copy `ios/Supabase.example.plist` to `ios/Finwaze/Config/Supabase.plist` to create it.
nonisolated struct SupabaseConfig: Sendable {
    let url: URL
    let publishableKey: String

    static func load(from bundle: Bundle = .main) -> SupabaseConfig {
        guard
            let fileURL = bundle.url(forResource: "Supabase", withExtension: "plist"),
            let data = try? Data(contentsOf: fileURL),
            let values = try? PropertyListDecoder().decode([String: String].self, from: data),
            let urlString = values["SUPABASE_URL"],
            let url = URL(string: urlString),
            let key = values["SUPABASE_PUBLISHABLE_KEY"]
        else {
            fatalError("Missing or invalid Config/Supabase.plist — copy it from ios/Supabase.example.plist")
        }
        return SupabaseConfig(url: url, publishableKey: key)
    }
}
