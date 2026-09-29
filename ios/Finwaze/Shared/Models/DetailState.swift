import Foundation

/// One record a screen loads fresh from the server, e.g. a goal or an account (`GEN-23…25`).
enum DetailState<Value> {
    case loading
    case loaded(Value)
    /// The record does not exist: deleted elsewhere, or never visible under RLS.
    case notFound
    case failed

    var value: Value? {
        if case .loaded(let value) = self { value } else { nil }
    }
}

extension DetailState: Equatable where Value: Equatable {}
