import Foundation
import Synchronization
@testable import Finwaze

final class FakeGoalsRepository: GoalsRepository {
    enum Call: Hashable {
        case goals, goal, overview, create, update, markDone, cancel, delete
    }

    private struct State {
        var goals: [SavingsGoal] = []
        var overview: [String: [MonthlySavings]] = [:]
        var failing: Set<Call> = []
        var calls: [Call] = []
        var queries: [GoalsQuery] = []
        var overviewRequests: [(year: Int, currencyCode: String)] = []
        var created: [NewSavingsGoal] = []
        var updated: [(id: Int64, update: SavingsGoalUpdate)] = []
        var markedDone: [Int64] = []
        var cancelled: [Int64] = []
        var deleted: [Int64] = []
    }

    private let state = Mutex(State())

    /// What `goals(_:)` answers, filtered by the query's status; `goal(id:)` looks it up here too.
    func setGoals(_ goals: [SavingsGoal]) {
        state.withLock { $0.goals = goals }
    }

    func setOverview(_ months: [MonthlySavings], for currencyCode: String) {
        state.withLock { $0.overview[currencyCode] = months }
    }

    func setFails(_ call: Call, _ fails: Bool = true) {
        state.withLock { state in
            if fails { state.failing.insert(call) } else { state.failing.remove(call) }
        }
    }

    var calls: [Call] { state.withLock { $0.calls } }
    var queries: [GoalsQuery] { state.withLock { $0.queries } }
    var overviewRequests: [(year: Int, currencyCode: String)] { state.withLock { $0.overviewRequests } }
    var created: [NewSavingsGoal] { state.withLock { $0.created } }
    var updated: [(id: Int64, update: SavingsGoalUpdate)] { state.withLock { $0.updated } }
    var markedDone: [Int64] { state.withLock { $0.markedDone } }
    var cancelled: [Int64] { state.withLock { $0.cancelled } }
    var deleted: [Int64] { state.withLock { $0.deleted } }

    func goals(_ query: GoalsQuery) async throws -> [SavingsGoal] {
        try record(.goals) { state in
            state.queries.append(query)
            return state.goals.filter { query.status == nil || $0.status == query.status }
        }
    }

    func goal(id: Int64) async throws -> SavingsGoal? {
        try record(.goal) { state in state.goals.first { $0.id == id } }
    }

    func savingsOverview(year: Int, currencyCode: String) async throws -> [MonthlySavings] {
        try record(.overview) { state in
            state.overviewRequests.append((year, currencyCode))
            return state.overview[currencyCode] ?? []
        }
    }

    func create(_ goal: NewSavingsGoal) async throws -> Int64 {
        try record(.create) { state in
            state.created.append(goal)
            return 500
        }
    }

    func update(id: Int64, _ update: SavingsGoalUpdate) async throws {
        try record(.update) { $0.updated.append((id, update)) }
    }

    func markDone(id: Int64) async throws {
        try record(.markDone) { $0.markedDone.append(id) }
    }

    func cancel(id: Int64) async throws {
        try record(.cancel) { $0.cancelled.append(id) }
    }

    func delete(id: Int64) async throws {
        try record(.delete) { $0.deleted.append(id) }
    }

    private func record<Value>(_ call: Call, _ body: (inout State) -> Value) throws -> Value {
        try state.withLock { state in
            state.calls.append(call)
            if state.failing.contains(call) {
                if [.goals, .goal, .overview].contains(call) { throw FakeLoadError() }
                throw FakeCreateError()
            }
            return body(&state)
        }
    }
}

extension SavingsGoal {
    /// A USD goal "Vacation" (id 101) due at the turn of 2027, unless told otherwise.
    static func fixture(
        id: Int64 = 101,
        name: String = "Vacation",
        currencyCode: String = "USD",
        targetDate: Date = Date(timeIntervalSince1970: 1_798_668_000),
        status: SavingsGoalStatus = .inProgress,
        target: Decimal = 1000,
        saved: Decimal = 400,
        hasTransfers: Bool = true
    ) -> SavingsGoal {
        SavingsGoal(
            id: id,
            name: name,
            currencyCode: currencyCode,
            targetDate: targetDate,
            status: status,
            targetAmount: target,
            accumulatedAmount: saved,
            hasTransfers: hasTransfers
        )
    }
}
