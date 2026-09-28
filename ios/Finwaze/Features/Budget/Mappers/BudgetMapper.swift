import Foundation

/// `null` counts as 0 and every amount becomes positive: the RPCs disagree on the sign of "spent" (see the DTOs), so
/// the absolute value is taken everywhere, like the web.
nonisolated enum BudgetMapper {
    static func toItem(_ dto: GroupMonthlyBudgetDto) -> BudgetItem {
        BudgetItem(
            id: dto.groupID,
            name: dto.groupName,
            planned: abs(dto.plannedAmount ?? 0),
            spent: abs(dto.spentAmount ?? 0),
            categoriesCount: dto.categoriesCount ?? 0,
            isUnplanned: dto.isUnplanned
        )
    }

    static func toItem(_ dto: CategoryMonthlyBudgetDto) -> BudgetItem {
        BudgetItem(
            id: dto.categoryID,
            name: dto.categoryName,
            planned: abs(dto.plannedAmount ?? 0),
            spent: abs(dto.spentAmount ?? 0),
            categoriesCount: nil,
            isUnplanned: dto.isUnplanned
        )
    }

    static func toTotals(_ dto: MonthlyBudgetTotalsDto?) -> BudgetTotals {
        guard let dto else { return .zero }
        return BudgetTotals(planned: abs(dto.plannedAmount ?? 0), spent: abs(dto.spentAmount ?? 0))
    }

    static func toExpense(_ dto: GroupMonthlyExpenseDto) -> MonthlyExpense {
        MonthlyExpense(
            id: dto.groupID,
            name: dto.groupName,
            amount: abs(dto.selectedMonthAmount ?? 0),
            previousAmount: abs(dto.previousMonthAmount ?? 0)
        )
    }

    static func toExpense(_ dto: CategoryMonthlyExpenseDto) -> MonthlyExpense {
        MonthlyExpense(
            id: dto.categoryID,
            name: dto.categoryName,
            amount: abs(dto.selectedMonthAmount ?? 0),
            previousAmount: abs(dto.previousMonthAmount ?? 0)
        )
    }

    // MARK: Plan (BUD-20…26)

    /// The month's plan: only categories with an amount — the server also returns spending without a plan, which the
    /// editor does not show (like the web).
    static func toPlan(_ dtos: [MonthlyBudgetDetailedDto]) -> [BudgetPlanLine] {
        dtos.map(toPlanLine).filter { $0.planned > 0 }
    }

    static func toPlanLine(_ dto: MonthlyBudgetDetailedDto) -> BudgetPlanLine {
        BudgetPlanLine(
            categoryID: dto.categoryID,
            categoryName: dto.categoryName,
            groupID: dto.groupID,
            groupName: dto.groupName,
            planned: abs(dto.plannedAmount ?? 0),
            stats: BudgetPlanStats(
                previousPlanned: abs(dto.previousPlannedAmount ?? 0),
                spent: abs(dto.spentAmount ?? 0),
                previousSpent: abs(dto.previousSpentAmount ?? 0)
            )
        )
    }

    static func toStats(_ dto: CategoryBudgetStatsDto?) -> BudgetPlanStats {
        guard let dto else { return .zero }
        return BudgetPlanStats(
            previousPlanned: abs(dto.previousPlannedAmount ?? 0),
            spent: abs(dto.spentAmount ?? 0),
            previousSpent: abs(dto.previousSpentAmount ?? 0)
        )
    }

    /// `p_categories` of `upsert_monthly_budgets`, by category id so the request is the same for the same plan.
    static func toPlanAmounts(_ amounts: [Int64: Decimal]) -> [BudgetPlanAmountDto] {
        amounts
            .sorted { $0.key < $1.key }
            .map { BudgetPlanAmountDto(categoryID: $0.key, plannedAmount: $0.value) }
    }
}
