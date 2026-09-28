import Foundation

/// "Total goals": how many goals the filters show, overall and by status (`GOAL-15`).
nonisolated struct GoalsSummary: Equatable, Sendable {
    let total: Int
    private let counts: [SavingsGoalStatus: Int]

    init(_ goals: [SavingsGoal]) {
        total = goals.count
        counts = Dictionary(grouping: goals, by: \.status).mapValues(\.count)
    }

    func count(_ status: SavingsGoalStatus) -> Int {
        counts[status] ?? 0
    }
}
