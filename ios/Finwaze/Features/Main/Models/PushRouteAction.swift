import SwiftUI

/// Pushes a route onto the section's navigation stack, for a screen inside it that has no access to the stack's path —
/// e.g. a Budget group card opening the group (`BUD-12`). The route needs a matching `navigationDestination`.
struct PushRouteAction {
    let push: (any Hashable) -> Void

    func callAsFunction(_ route: some Hashable) {
        push(route)
    }
}

extension EnvironmentValues {
    /// Does nothing outside a section's stack.
    @Entry var pushRoute = PushRouteAction { _ in }
}
