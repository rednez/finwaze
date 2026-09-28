import Foundation

/// A group's budget screen, pushed from its card (`BUD-12`, `BUD-17`). The name comes with it, so the screen needs no
/// extra request for its title.
struct BudgetGroupRoute: Hashable {
    let id: Int64
    let name: String
}
