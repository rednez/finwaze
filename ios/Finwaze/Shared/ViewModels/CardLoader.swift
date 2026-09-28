import Foundation
import Observation

/// One card's data for what its filters select (its key), loaded, reloaded and retried on its own, so another card's
/// filters or failure never touch it (`GEN-25`).
@Observable
final class CardLoader<Key: Equatable, Value: Equatable & Sendable> {
    private(set) var state: CardState<Value> = .loading

    @ObservationIgnored private let currentKey: () -> Key?
    @ObservationIgnored private let fetch: (Key) async throws -> Value
    /// What `state` holds data for, and the data version it was loaded at.
    @ObservationIgnored private var shownKey: Key?
    @ObservationIgnored private var shownDataVersion: Int?
    /// The latest data version the view asked for.
    @ObservationIgnored private var dataVersion = 0

    /// - Parameters:
    ///   - key: What the card should show now, read from its filters; `nil` when there is nothing to show it in,
    ///     e.g. without accounts.
    ///   - fetch: Loads the data for a key.
    init(key: @escaping () -> Key?, fetch: @escaping (Key) async throws -> Value) {
        currentKey = key
        self.fetch = fetch
    }

    var key: Key? {
        currentKey()
    }

    /// Brings the card up to date. Another key shows a skeleton — figures of the previous one would be wrong; a change
    /// to the data keeps the figures until the new ones arrive (`GEN-26`). Nothing loads when both are as shown, e.g.
    /// when coming back to the screen.
    func load(dataVersion: Int) async {
        self.dataVersion = dataVersion
        guard let key else {
            // Only without accounts, which the main app never is (`NAV-07`).
            state = .failed
            return
        }
        if key != shownKey {
            state = .loading
        } else if dataVersion == shownDataVersion, state != .loading {
            return
        }
        await reload(key)
    }

    /// Pull to refresh or "Try again": reloads, keeping the figures until the new ones arrive.
    func refresh() async {
        guard let key else { return }
        await reload(key)
    }

    private func reload(_ key: Key) async {
        let dataVersion = dataVersion
        if case .failed = state {
            state = .loading
        }
        let result: CardState<Value>
        do {
            result = .loaded(try await fetch(key))
        } catch {
            result = .failed
        }
        // A response for a key no longer selected, or for a load the view gave up on, is dropped.
        guard !Task.isCancelled, self.key == key else { return }
        state = result
        shownKey = key
        shownDataVersion = dataVersion
    }
}
