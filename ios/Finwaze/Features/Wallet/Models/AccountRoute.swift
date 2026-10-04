import Foundation

/// Pushes "Account settings" onto the Wallet's navigation stack (`ACC-02`).
nonisolated struct AccountRoute: Hashable {
    let id: Int64
    /// The account as its card showed it, so the form is there from the first frame of the zoom while the fresh
    /// details load. Not part of the route's identity.
    var preview: WalletAccount?

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
