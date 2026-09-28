import Foundation
import Synchronization
@testable import Finwaze

final class FakeAnalyticsRepository: AnalyticsRepository {
    enum Call: Hashable {
        case summary, dailyOverview, amountsByGroup, yearly
    }

    private struct State {
        var summaries: [AnalyticsQuery: AnalyticsSummary] = [:]
        var days: [AnalyticsQuery: [DailyOverviewPoint]] = [:]
        var amounts: [AnalyticsQuery: [GroupAmounts]] = [:]
        var years: [AnalyticsYearKey: [MonthlyBudgetExpense]] = [:]
        var failing: Set<Call> = []
        var queries: [(call: Call, query: AnalyticsQuery)] = []
        var yearKeys: [AnalyticsYearKey] = []
    }

    private let state = Mutex(State())

    func setSummary(_ summary: AnalyticsSummary, for query: AnalyticsQuery) {
        state.withLock { $0.summaries[query] = summary }
    }

    func setDays(_ days: [DailyOverviewPoint], for query: AnalyticsQuery) {
        state.withLock { $0.days[query] = days }
    }

    func setAmounts(_ amounts: [GroupAmounts], for query: AnalyticsQuery) {
        state.withLock { $0.amounts[query] = amounts }
    }

    func setYear(_ months: [MonthlyBudgetExpense], for key: AnalyticsYearKey) {
        state.withLock { $0.years[key] = months }
    }

    func setFails(_ call: Call, _ fails: Bool = true) {
        state.withLock { state in
            if fails { state.failing.insert(call) } else { state.failing.remove(call) }
        }
    }

    /// The queries `call` was made with, in call order.
    func queries(_ call: Call) -> [AnalyticsQuery] {
        state.withLock { $0.queries.filter { $0.call == call }.map(\.query) }
    }

    var yearKeys: [AnalyticsYearKey] {
        state.withLock { $0.yearKeys }
    }

    func summary(_ query: AnalyticsQuery) async throws -> AnalyticsSummary {
        try record(.summary, query) { $0.summaries[query] ?? .zero }
    }

    func dailyOverview(_ query: AnalyticsQuery) async throws -> [DailyOverviewPoint] {
        try record(.dailyOverview, query) { $0.days[query] ?? [] }
    }

    func amountsByGroup(_ query: AnalyticsQuery) async throws -> [GroupAmounts] {
        try record(.amountsByGroup, query) { $0.amounts[query] ?? [] }
    }

    func yearlyBudgetsVsExpenses(year: Int, currencyCode: String) async throws -> [MonthlyBudgetExpense] {
        let key = AnalyticsYearKey(year: year, currencyCode: currencyCode)
        return try state.withLock { state in
            state.yearKeys.append(key)
            if state.failing.contains(.yearly) { throw FakeLoadError() }
            return state.years[key] ?? []
        }
    }

    private func record<Value>(_ call: Call, _ query: AnalyticsQuery, _ value: (State) -> Value) throws -> Value {
        try state.withLock { state in
            state.queries.append((call, query))
            if state.failing.contains(call) { throw FakeLoadError() }
            return value(state)
        }
    }
}
