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
}
