import Foundation

/// The Goals screen's filters (`GOAL-10`): goals due on or after 1 January of `year`, in `status` or any.
nonisolated struct GoalsQuery: Hashable, Sendable {
    let year: Int
    /// `nil` for every status.
    let status: SavingsGoalStatus?

    /// `p_period_from`: `"2026-01-01"`.
    var periodFromParameter: String {
        String(format: "%04d-01-01", year)
    }
}
