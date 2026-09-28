import Foundation
import Synchronization
@testable import Finwaze

final class FakeDashboardRepository: DashboardRepository {
    private struct State {
        var totalsByCurrency: [String: DashboardTotals] = [:]
        var cashFlow: [MonthlyCashFlow] = []
        var budgetsByCurrency: [String: [CategoryBudget]] = [:]
        var recentTransactions: [Transaction] = []
        var goals: [SavingsGoal] = []
        var failing: Set<DashboardViewModel.Card> = []
        /// Calls per card, in order, with the currency each was asked for (`nil` when the card has none).
        var calls: [(card: DashboardViewModel.Card, currencyCode: String?)] = []
    }

    private let state = Mutex(State())

    func setTotals(_ totals: DashboardTotals, currencyCode: String) {
        state.withLock { $0.totalsByCurrency[currencyCode] = totals }
    }

    func setCashFlow(_ cashFlow: [MonthlyCashFlow]) {
        state.withLock { $0.cashFlow = cashFlow }
    }

    func setBudgets(_ budgets: [CategoryBudget], currencyCode: String) {
        state.withLock { $0.budgetsByCurrency[currencyCode] = budgets }
    }

    func setRecentTransactions(_ transactions: [Transaction]) {
        state.withLock { $0.recentTransactions = transactions }
    }

    func setGoals(_ goals: [SavingsGoal]) {
        state.withLock { $0.goals = goals }
    }

    func setFails(_ card: DashboardViewModel.Card, _ fails: Bool = true) {
        state.withLock { state in
            if fails { state.failing.insert(card) } else { state.failing.remove(card) }
        }
    }

    /// How many times each card was loaded.
    func loads(_ card: DashboardViewModel.Card) -> Int {
        state.withLock { $0.calls.count { $0.card == card } }
    }

    /// The currencies `card` was loaded in, in call order.
    func currencies(_ card: DashboardViewModel.Card) -> [String?] {
        state.withLock { $0.calls.filter { $0.card == card }.map(\.currencyCode) }
    }

    func totals(currencyCode: String) async throws -> DashboardTotals {
        try record(.totals, currencyCode) { $0.totalsByCurrency[currencyCode] ?? .zero }
    }

    func monthlyCashFlow(currencyCode: String, months: Int) async throws -> [MonthlyCashFlow] {
        try record(.cashFlow, currencyCode) { $0.cashFlow }
    }

    func currentMonthBudgets(currencyCode: String) async throws -> [CategoryBudget] {
        try record(.budget, currencyCode) { $0.budgetsByCurrency[currencyCode] ?? [] }
    }

    func recentTransactions(limit: Int) async throws -> [Transaction] {
        try record(.recentTransactions, nil) { Array($0.recentTransactions.prefix(limit)) }
    }

    func recentGoals(limit: Int) async throws -> [SavingsGoal] {
        try record(.goals, nil) { Array($0.goals.prefix(limit)) }
    }

    private func record<Value>(
        _ card: DashboardViewModel.Card,
        _ currencyCode: String?,
        _ value: (State) -> Value
    ) throws -> Value {
        try state.withLock { state in
            state.calls.append((card, currencyCode))
            if state.failing.contains(card) { throw FakeLoadError() }
            return value(state)
        }
    }
}
