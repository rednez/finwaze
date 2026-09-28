import Foundation
import Supabase

/// The same RPCs as the web's `AnalyticsRepository`, from `supabase/schemas/charts_funcs.sql` and
/// `monthly_budgets_funcs.sql`.
nonisolated struct SupabaseAnalyticsRepository: AnalyticsRepository {
    let client: SupabaseClient

    func summary(_ query: AnalyticsQuery) async throws -> AnalyticsSummary {
        let dtos: [AnalyticsSummaryDto] = try await client
            .rpc("get_analytics_financial_summary", params: AnalyticsParams(query))
            .execute()
            .value
        return AnalyticsMapper.toSummary(dtos.first)
    }

    func dailyOverview(_ query: AnalyticsQuery) async throws -> [DailyOverviewPoint] {
        let dtos: [DailyOverviewPointDto] = try await client
            .rpc("get_daily_financial_overview_for_month", params: AnalyticsParams(query))
            .execute()
            .value
        return try dtos.map { try AnalyticsMapper.toDailyPoint($0) }
    }

    func amountsByGroup(_ query: AnalyticsQuery) async throws -> [GroupAmounts] {
        let dtos: [AnalyticsGroupAmountsDto] = try await client
            .rpc("get_analytics_amounts_by_groups", params: AnalyticsParams(query))
            .execute()
            .value
        return dtos.map(AnalyticsMapper.toGroupAmounts)
    }

    func yearlyBudgetsVsExpenses(year: Int, currencyCode: String) async throws -> [MonthlyBudgetExpense] {
        let dtos: [MonthlyBudgetExpenseDto] = try await client
            .rpc("get_yearly_budgets_vs_expenses", params: AnalyticsYearParams(year: year, currencyCode: currencyCode))
            .execute()
            .value
        return try AnalyticsMapper.toYear(dtos)
    }
}

/// The parameters of the month's analytics functions.
nonisolated struct AnalyticsParams: Encodable, Equatable, Sendable {
    let month: String
    let currencyCode: String
    /// Left out of the JSON for every account: the functions' `DEFAULT NULL` then counts all of the currency's,
    /// goal accounts included, so the balance matches the Dashboard's.
    let accountIDs: [Int64]?

    init(_ query: AnalyticsQuery) {
        month = query.month.firstDayParameter
        currencyCode = query.currencyCode
        accountIDs = query.accountIDs.isEmpty ? nil : query.accountIDs.sorted()
    }

    enum CodingKeys: String, CodingKey {
        case month = "p_month"
        case currencyCode = "p_currency_code"
        case accountIDs = "p_account_ids"
    }
}

/// The parameters of `get_yearly_budgets_vs_expenses`.
nonisolated struct AnalyticsYearParams: Encodable, Equatable, Sendable {
    let year: Int
    let currencyCode: String

    enum CodingKeys: String, CodingKey {
        case year = "p_year"
        case currencyCode = "p_currency_code"
    }
}
