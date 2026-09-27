import Foundation
import Supabase

/// The single shared `SupabaseClient`. Repositories receive `client` through their initializers.
nonisolated enum SupabaseProvider {
    static let config = SupabaseConfig.load()

    static let client: SupabaseClient = SupabaseClient(
        supabaseURL: config.url,
        supabaseKey: config.publishableKey,
        options: SupabaseClientOptions(
            auth: .init(emitLocalSessionAsInitialSession: true)
        )
    )
}
