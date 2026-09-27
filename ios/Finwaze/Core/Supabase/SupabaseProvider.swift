import Foundation
import Supabase

/// The single shared `SupabaseClient`. Repositories receive `client` through their initializers.
nonisolated enum SupabaseProvider {
    static let client: SupabaseClient = {
        let config = SupabaseConfig.load()
        return SupabaseClient(
            supabaseURL: config.url,
            supabaseKey: config.publishableKey,
            options: SupabaseClientOptions(
                auth: .init(emitLocalSessionAsInitialSession: true)
            )
        )
    }()
}
