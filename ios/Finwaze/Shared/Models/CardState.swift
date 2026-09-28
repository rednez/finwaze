import Foundation

/// One card's data with its own loading and error states, so a failing card leaves the others intact
/// (`DASH-08`, `GEN-23…25`).
nonisolated enum CardState<Value: Equatable & Sendable>: Equatable, Sendable {
    case loading
    case loaded(Value)
    case failed

    var value: Value? {
        if case .loaded(let value) = self { value } else { nil }
    }
}
