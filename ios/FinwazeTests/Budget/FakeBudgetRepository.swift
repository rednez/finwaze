import Foundation
import Synchronization
@testable import Finwaze

final class FakeBudgetRepository: BudgetRepository {
    /// The plan editor's calls (`BUD-20…26`).
    enum PlanCall: Hashable {
        case plan, generate, stats, save
    }

    private struct State {
        var budgets: [BudgetQuery: [BudgetItem]] = [:]
        var totals: [BudgetQuery: BudgetTotals] = [:]
        var expenses: [BudgetQuery: [MonthlyExpense]] = [:]
        var failing: Set<BudgetViewModel.Card> = []
        /// Every call, in order, with the query it was asked for.
        var calls: [(card: BudgetViewModel.Card, query: BudgetQuery)] = []
        var plan: [BudgetPlanLine] = []
        var generatedPlan: [BudgetPlanLine] = []
        var stats: [Int64: BudgetPlanStats] = [:]
        var failingPlanCalls: Set<PlanCall> = []
        var planCalls: [PlanCall] = []
        /// Every saved plan, in call order.
        var savedPlans: [[Int64: Decimal]] = []
    }

    private let state = Mutex(State())

    func setBudgets(_ budgets: [BudgetItem], for query: BudgetQuery) {
        state.withLock { $0.budgets[query] = budgets }
    }

    func setTotals(_ totals: BudgetTotals, for query: BudgetQuery) {
        state.withLock { $0.totals[query] = totals }
    }

    func setExpenses(_ expenses: [MonthlyExpense], for query: BudgetQuery) {
        state.withLock { $0.expenses[query] = expenses }
    }

    func setFails(_ card: BudgetViewModel.Card, _ fails: Bool = true) {
        state.withLock { state in
            if fails { state.failing.insert(card) } else { state.failing.remove(card) }
        }
    }

    /// How many times `card` was loaded.
    func loads(_ card: BudgetViewModel.Card) -> Int {
        state.withLock { $0.calls.count { $0.card == card } }
    }

    /// The queries `card` was loaded for, in call order.
    func queries(_ card: BudgetViewModel.Card) -> [BudgetQuery] {
        state.withLock { $0.calls.filter { $0.card == card }.map(\.query) }
    }

    var callCount: Int {
        state.withLock { $0.calls.count }
    }

    func setPlan(_ lines: [BudgetPlanLine]) {
        state.withLock { $0.plan = lines }
    }

    func setGeneratedPlan(_ lines: [BudgetPlanLine]) {
        state.withLock { $0.generatedPlan = lines }
    }

    func setStats(_ stats: BudgetPlanStats, for categoryID: Int64) {
        state.withLock { $0.stats[categoryID] = stats }
    }

    func setFails(_ call: PlanCall, _ fails: Bool = true) {
        state.withLock { state in
            if fails { state.failingPlanCalls.insert(call) } else { state.failingPlanCalls.remove(call) }
        }
    }

    var planCalls: [PlanCall] {
        state.withLock { $0.planCalls }
    }

    var savedPlans: [[Int64: Decimal]] {
        state.withLock { $0.savedPlans }
    }

    func budgets(_ query: BudgetQuery) async throws -> [BudgetItem] {
        try record(.budgets, query) { $0.budgets[query] ?? [] }
    }

    func totals(_ query: BudgetQuery) async throws -> BudgetTotals {
        try record(.totals, query) { $0.totals[query] ?? .zero }
    }

    func expenses(_ query: BudgetQuery) async throws -> [MonthlyExpense] {
        try record(.expenses, query) { $0.expenses[query] ?? [] }
    }

    func plan(month: YearMonth, currencyCode: String) async throws -> [BudgetPlanLine] {
        try recordPlan(.plan) { $0.plan }
    }

    func generatedPlan(month: YearMonth, currencyCode: String) async throws -> [BudgetPlanLine] {
        try recordPlan(.generate) { $0.generatedPlan }
    }

    func categoryStats(month: YearMonth, currencyCode: String, categoryID: Int64) async throws -> BudgetPlanStats {
        try recordPlan(.stats) { $0.stats[categoryID] ?? .zero }
    }

    func savePlan(month: YearMonth, currencyCode: String, amounts: [Int64: Decimal]) async throws {
        try state.withLock { state in
            state.planCalls.append(.save)
            if state.failingPlanCalls.contains(.save) { throw FakeCreateError() }
            state.savedPlans.append(amounts)
        }
    }

    private func recordPlan<Value>(_ call: PlanCall, _ value: (State) -> Value) throws -> Value {
        try state.withLock { state in
            state.planCalls.append(call)
            if state.failingPlanCalls.contains(call) { throw FakeLoadError() }
            return value(state)
        }
    }

    private func record<Value>(
        _ card: BudgetViewModel.Card,
        _ query: BudgetQuery,
        _ value: (State) -> Value
    ) throws -> Value {
        try state.withLock { state in
            state.calls.append((card, query))
            if state.failing.contains(card) { throw FakeLoadError() }
            return value(state)
        }
    }
}
