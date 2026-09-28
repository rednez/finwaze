import Foundation

/// Savings goals (`GOAL-01…26`). Deposits and withdrawals are transfers and go through `TransfersRepository`
/// (`GOAL-03`).
protocol GoalsRepository: Sendable {
    /// The goals the filters show, newest first (`GOAL-10`).
    func goals(_ query: GoalsQuery) async throws -> [SavingsGoal]
    /// One goal, fresh from the server; `nil` when it does not exist (`GOAL-26`).
    func goal(id: Int64) async throws -> SavingsGoal?
    /// Net deposits into the goals in `currencyCode` for each month of `year`, with the year before (`GOAL-16`).
    func savingsOverview(year: Int, currencyCode: String) async throws -> [MonthlySavings]
    /// Creates the goal with its own account; returns the goal's id (`GOAL-21`).
    func create(_ goal: NewSavingsGoal) async throws -> Int64
    /// Renames the goal and changes its target (`GOAL-20`).
    func update(id: Int64, _ update: SavingsGoalUpdate) async throws
    /// Marks the goal as done (`GOAL-23`).
    func markDone(id: Int64) async throws
    /// Marks the goal as cancelled (`GOAL-24`).
    func cancel(id: Int64) async throws
    /// Deletes the goal with its account (`GOAL-25`).
    func delete(id: Int64) async throws
}
