import Foundation
import Supabase

/// The same RPCs as the web's `GoalsRepository`, from `supabase/schemas/savings_goals.sql`.
nonisolated struct SupabaseGoalsRepository: GoalsRepository {
    let client: SupabaseClient

    private struct ListParams: Encodable {
        /// Left out of the JSON when `nil`, so the SQL default (every status) applies.
        let status: String?
        let periodFrom: String

        enum CodingKeys: String, CodingKey {
            case status = "p_status"
            case periodFrom = "p_period_from"
        }
    }

    private struct OverviewParams: Encodable {
        let year: Int
        let currencyCode: String

        enum CodingKeys: String, CodingKey {
            case year = "p_year"
            case currencyCode = "p_currency_code"
        }
    }

    private struct IDParams: Encodable {
        let accountID: Int64

        enum CodingKeys: String, CodingKey {
            case accountID = "p_account_id"
        }
    }

    func goals(_ query: GoalsQuery) async throws -> [SavingsGoal] {
        let dtos: [SavingsGoalDto] = try await client
            .rpc(
                "get_savings_goals",
                params: ListParams(status: query.status?.rawValue, periodFrom: query.periodFromParameter)
            )
            .execute()
            .value
        return try dtos.map { try SavingsGoalsMapper.toGoal($0) }
    }

    func goal(id: Int64) async throws -> SavingsGoal? {
        // Like the web: every goal, filtered to the one; a deleted goal simply yields zero rows.
        let dtos: [SavingsGoalDto] = try await client
            .rpc("get_savings_goals")
            .eq("id", value: Int(id))
            .execute()
            .value
        return try dtos.first.map { try SavingsGoalsMapper.toGoal($0) }
    }

    func savingsOverview(year: Int, currencyCode: String) async throws -> [MonthlySavings] {
        let dtos: [MonthlySavingsDto] = try await client
            .rpc("get_monthly_savings_overview", params: OverviewParams(year: year, currencyCode: currencyCode))
            .execute()
            .value
        return try dtos.map(SavingsGoalsMapper.toMonthlySavings)
    }

    func create(_ goal: NewSavingsGoal) async throws -> Int64 {
        try await client
            .rpc("create_savings_goal", params: SavingsGoalsMapper.toDto(goal))
            .execute()
            .value
    }

    func update(id: Int64, _ update: SavingsGoalUpdate) async throws {
        try await client
            .rpc("update_savings_goal", params: SavingsGoalsMapper.toDto(id: id, update))
            .execute()
    }

    func markDone(id: Int64) async throws {
        try await call("mark_savings_goal_as_done", id: id)
    }

    func cancel(id: Int64) async throws {
        try await call("cancel_savings_goal", id: id)
    }

    func delete(id: Int64) async throws {
        try await call("delete_savings_goal", id: id)
    }

    private func call(_ function: String, id: Int64) async throws {
        try await client
            .rpc(function, params: IDParams(accountID: id))
            .execute()
    }
}
