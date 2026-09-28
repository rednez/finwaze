import Foundation

/// Row of `get_monthly_budget_totals` and `get_monthly_budget_totals_by_group`. `spent_amount` comes positive.
nonisolated struct MonthlyBudgetTotalsDto: Decodable, Sendable {
    let plannedAmount: Decimal?
    let spentAmount: Decimal?

    enum CodingKeys: String, CodingKey {
        case plannedAmount = "planned_amount"
        case spentAmount = "spent_amount"
    }
}
