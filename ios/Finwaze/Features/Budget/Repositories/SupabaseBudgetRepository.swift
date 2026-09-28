import Foundation
import Supabase

/// The same RPCs as the web's `BudgetRepository`, from `supabase/schemas/monthly_budgets_funcs.sql`.
nonisolated struct SupabaseBudgetRepository: BudgetRepository {
    let client: SupabaseClient

    private struct Params: Encodable {
        let month: String
        let currencyCode: String
        /// Left out of the JSON when `nil`: the month-wide functions have no such parameter.
        let groupID: Int64?

        init(_ query: BudgetQuery) {
            month = query.month.firstDayParameter
            currencyCode = query.currencyCode
            groupID = query.groupID
        }

        enum CodingKeys: String, CodingKey {
            case month = "p_month"
            case currencyCode = "p_currency_code"
            case groupID = "p_group_id"
        }
    }

    func budgets(_ query: BudgetQuery) async throws -> [BudgetItem] {
        if query.groupID == nil {
            let dtos: [GroupMonthlyBudgetDto] = try await call("get_monthly_budgets_by_groups", query)
            return dtos.map(BudgetMapper.toItem)
        } else {
            let dtos: [CategoryMonthlyBudgetDto] = try await call("get_monthly_budgets_by_categories", query)
            return dtos.map(BudgetMapper.toItem)
        }
    }

    func totals(_ query: BudgetQuery) async throws -> BudgetTotals {
        let function = query.groupID == nil ? "get_monthly_budget_totals" : "get_monthly_budget_totals_by_group"
        let dtos: [MonthlyBudgetTotalsDto] = try await call(function, query)
        return BudgetMapper.toTotals(dtos.first)
    }

    func expenses(_ query: BudgetQuery) async throws -> [MonthlyExpense] {
        if query.groupID == nil {
            let dtos: [GroupMonthlyExpenseDto] = try await call("get_monthly_expenses_by_groups", query)
            return dtos.map(BudgetMapper.toExpense)
        } else {
            let dtos: [CategoryMonthlyExpenseDto] = try await call("get_monthly_expenses_by_categories", query)
            return dtos.map(BudgetMapper.toExpense)
        }
    }

    // MARK: Plan (BUD-20…26)

    private struct PlanParams: Encodable {
        let month: String
        let currencyCode: String
        var categoryID: Int64?
        var categories: [BudgetPlanAmountDto]?

        enum CodingKeys: String, CodingKey {
            case month = "p_month"
            case currencyCode = "p_currency_code"
            case categoryID = "p_category_id"
            case categories = "p_categories"
        }
    }

    func plan(month: YearMonth, currencyCode: String) async throws -> [BudgetPlanLine] {
        let dtos: [MonthlyBudgetDetailedDto] = try await client
            .rpc(
                "get_monthly_budgets_detailed",
                params: PlanParams(month: month.firstDayParameter, currencyCode: currencyCode)
            )
            .execute()
            .value
        return BudgetMapper.toPlan(dtos)
    }

    func generatedPlan(month: YearMonth, currencyCode: String) async throws -> [BudgetPlanLine] {
        let dtos: [MonthlyBudgetDetailedDto] = try await client
            .rpc(
                "generate_monthly_budgets_from_previous",
                params: PlanParams(month: month.firstDayParameter, currencyCode: currencyCode)
            )
            .execute()
            .value
        return BudgetMapper.toPlan(dtos)
    }

    func categoryStats(month: YearMonth, currencyCode: String, categoryID: Int64) async throws -> BudgetPlanStats {
        let dtos: [CategoryBudgetStatsDto] = try await client
            .rpc(
                "get_category_budget_stats",
                params: PlanParams(month: month.firstDayParameter, currencyCode: currencyCode, categoryID: categoryID)
            )
            .execute()
            .value
        return BudgetMapper.toStats(dtos.first)
    }

    func savePlan(month: YearMonth, currencyCode: String, amounts: [Int64: Decimal]) async throws {
        try await client
            .rpc(
                "upsert_monthly_budgets",
                params: PlanParams(
                    month: month.firstDayParameter,
                    currencyCode: currencyCode,
                    categories: BudgetMapper.toPlanAmounts(amounts)
                )
            )
            .execute()
    }

    private func call<Row: Decodable & Sendable>(_ function: String, _ query: BudgetQuery) async throws -> [Row] {
        try await client
            .rpc(function, params: Params(query))
            .execute()
            .value
    }
}
