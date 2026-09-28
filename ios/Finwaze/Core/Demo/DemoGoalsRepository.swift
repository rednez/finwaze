import Foundation

/// Demo-mode Goals (`AUTH-10`): the goals from `DemoData`, never from the network. The overview uses the web demo's
/// figures for the demo goals' currencies. Every write succeeds without changing anything, so the demo always shows
/// the same goals; deposits and withdrawals go through `DemoTransfersRepository`, which does the same.
nonisolated struct DemoGoalsRepository: GoalsRepository {
    var calendar: Calendar = .current
    var now: @Sendable () -> Date = { .now }

    /// Like the web demo: an id for a goal that is never stored.
    static let createdGoalID: Int64 = 9999

    func goals(_ query: GoalsQuery) async throws -> [SavingsGoal] {
        let periodStart = calendar.date(from: DateComponents(year: query.year, month: 1, day: 1)) ?? .distantPast
        return allGoals().filter { goal in
            goal.targetDate >= periodStart && (query.status == nil || goal.status == query.status)
        }
    }

    func goal(id: Int64) async throws -> SavingsGoal? {
        allGoals().first { $0.id == id }
    }

    /// The web demo's `buildSavingsOverview`: 200 + 30 a month this year, 150 + 25 a month the year before.
    func savingsOverview(year: Int, currencyCode: String) async throws -> [MonthlySavings] {
        let hasGoals = allGoals().contains { $0.currencyCode == currencyCode }
        return (1...12).map { month in
            MonthlySavings(
                month: YearMonth(year: year, month: month),
                currentYear: hasGoals ? Decimal(200 + (month - 1) * 30) : 0,
                previousYear: hasGoals ? Decimal(150 + (month - 1) * 25) : 0
            )
        }
    }

    func create(_ goal: NewSavingsGoal) async throws -> Int64 {
        Self.createdGoalID
    }

    func update(id: Int64, _ update: SavingsGoalUpdate) async throws {}

    func markDone(id: Int64) async throws {}

    func cancel(id: Int64) async throws {}

    func delete(id: Int64) async throws {}

    private func allGoals() -> [SavingsGoal] {
        DemoData.savingsGoals(now: now(), calendar: calendar)
    }
}
