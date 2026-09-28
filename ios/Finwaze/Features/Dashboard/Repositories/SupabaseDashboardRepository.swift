import Foundation
import Supabase

/// The same RPCs as the web's `DashboardRepository`.
nonisolated struct SupabaseDashboardRepository: DashboardRepository {
    let client: SupabaseClient

    private struct CurrencyParams: Encodable {
        let currencyCode: String

        enum CodingKeys: String, CodingKey {
            case currencyCode = "p_currency_code"
        }
    }

    private struct CashFlowParams: Encodable {
        let currencyCode: String
        let months: Int

        enum CodingKeys: String, CodingKey {
            case currencyCode = "p_currency_code"
            case months = "p_months"
        }
    }

    private struct LimitParams: Encodable {
        let limit: Int

        enum CodingKeys: String, CodingKey {
            case limit = "p_limit"
        }
    }

    func totals(currencyCode: String) async throws -> DashboardTotals {
        let dtos: [DashboardTotalsDto] = try await client
            .rpc("get_dashboard_totals", params: CurrencyParams(currencyCode: currencyCode))
            .execute()
            .value
        return DashboardMapper.toTotals(dtos.first)
    }

    func monthlyCashFlow(currencyCode: String, months: Int) async throws -> [MonthlyCashFlow] {
        let dtos: [MonthlyCashFlowDto] = try await client
            .rpc("get_monthly_charged_cash_flow", params: CashFlowParams(currencyCode: currencyCode, months: months))
            .execute()
            .value
        return try DashboardMapper.toCashFlow(dtos, months: months)
    }

    func currentMonthBudgets(currencyCode: String) async throws -> [CategoryBudget] {
        let dtos: [CategoryBudgetDto] = try await client
            .rpc("get_current_month_budgets_by_category", params: CurrencyParams(currencyCode: currencyCode))
            .execute()
            .value
        return dtos.map(DashboardMapper.toBudget)
    }

    func recentTransactions(limit: Int) async throws -> [Transaction] {
        // The same row as `get_filtered_transactions`.
        let dtos: [TransactionDto] = try await client
            .rpc("get_recent_transactions", params: LimitParams(limit: limit))
            .execute()
            .value
        return try dtos.map(TransactionMapper.toTransaction)
    }

    func recentGoals(limit: Int) async throws -> [SavingsGoal] {
        let dtos: [SavingsGoalDto] = try await client
            .rpc("get_savings_goals", params: LimitParams(limit: limit))
            .execute()
            .value
        return try dtos.map { try SavingsGoalsMapper.toGoal($0) }
    }
}
