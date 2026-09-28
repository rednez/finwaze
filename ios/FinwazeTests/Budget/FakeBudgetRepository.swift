import Foundation
import Synchronization
@testable import Finwaze

final class FakeBudgetRepository: BudgetRepository {
    private struct State {
        var budgets: [BudgetQuery: [BudgetItem]] = [:]
        var totals: [BudgetQuery: BudgetTotals] = [:]
        var expenses: [BudgetQuery: [MonthlyExpense]] = [:]
        var failing: Set<BudgetViewModel.Card> = []
        /// Every call, in order, with the query it was asked for.
        var calls: [(card: BudgetViewModel.Card, query: BudgetQuery)] = []
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

    func budgets(_ query: BudgetQuery) async throws -> [BudgetItem] {
        try record(.budgets, query) { $0.budgets[query] ?? [] }
    }

    func totals(_ query: BudgetQuery) async throws -> BudgetTotals {
        try record(.totals, query) { $0.totals[query] ?? .zero }
    }

    func expenses(_ query: BudgetQuery) async throws -> [MonthlyExpense] {
        try record(.expenses, query) { $0.expenses[query] ?? [] }
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
