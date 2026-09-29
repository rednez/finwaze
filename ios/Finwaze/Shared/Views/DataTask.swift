import SwiftUI

extension View {
    /// Runs `action` when the view appears, and again when `key` — what its filters select — or the data change
    /// (`GEN-26`).
    func task<Key: Equatable>(
        for key: Key,
        dataVersion: Int,
        _ action: @escaping @MainActor @Sendable () async -> Void
    ) -> some View {
        task(id: DataTaskID(key: key, dataVersion: dataVersion)) { await action() }
    }
}

private struct DataTaskID<Key: Equatable>: Equatable {
    let key: Key
    let dataVersion: Int
}
