import Foundation

/// One element of `upsert_monthly_budgets`' `p_categories`. The amount is encoded as a JSON number straight from
/// `Decimal`, so `0.1` stays `0.1` (`GEN-09`).
nonisolated struct BudgetPlanAmountDto: Encodable, Equatable, Sendable {
    let categoryID: Int64
    let plannedAmount: Decimal

    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case plannedAmount = "planned_amount"
    }
}
