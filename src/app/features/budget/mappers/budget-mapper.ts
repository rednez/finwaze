import { Injectable } from '@angular/core';
import {
  BudgetCategoryRow,
  BudgetGroupRow,
  CategoryMonthlyBudget,
  CategoryMonthlyBudgetDto,
  GroupMonthlyBudget,
  GroupMonthlyBudgetDto,
  MonthlyBudgetDetailedDto,
  MonthlyBudgetTotals,
  MonthlyBudgetTotalsDto,
  MonthlyExpense,
  MonthlyExpenseByCategoryDto,
  MonthlyExpenseByGroupDto,
} from '../models';

@Injectable({
  providedIn: 'root',
})
export class BudgetMapper {
  fromGroupMonthlyBudgetDto(dto: GroupMonthlyBudgetDto): GroupMonthlyBudget {
    return {
      id: dto.group_id,
      name: dto.group_name,
      plannedAmount: dto.planned_amount,
      spentAmount: Math.abs(dto.spent_amount),
      isUnplanned: dto.is_unplanned,
      categoriesCount: dto.categories_count,
    };
  }

  fromCategoryMonthlyBudgetDto(
    dto: CategoryMonthlyBudgetDto,
  ): CategoryMonthlyBudget {
    return {
      id: dto.category_id,
      name: dto.category_name,
      plannedAmount: dto.planned_amount,
      spentAmount: Math.abs(dto.spent_amount),
      isUnplanned: dto.is_unplanned,
    };
  }

  fromMonthlyBudgetTotalsDto(dto: MonthlyBudgetTotalsDto): MonthlyBudgetTotals {
    return {
      plannedAmount: dto.planned_amount,
      spentAmount: Math.abs(dto.spent_amount),
    };
  }

  fromMonthlyExpenseByGroupDto(dto: MonthlyExpenseByGroupDto): MonthlyExpense {
    return {
      id: dto.group_id,
      name: dto.group_name,
      selectedMonthAmount: dto.selected_month_amount,
      previousMonthAmount: dto.previous_month_amount,
    };
  }

  fromMonthlyExpenseByCategoryDto(
    dto: MonthlyExpenseByCategoryDto,
  ): MonthlyExpense {
    return {
      id: dto.category_id,
      name: dto.category_name,
      selectedMonthAmount: dto.selected_month_amount,
      previousMonthAmount: dto.previous_month_amount,
    };
  }

  fromDetailedBudgetDtosToGroupRows(
    dtos: MonthlyBudgetDetailedDto[],
  ): BudgetGroupRow[] {
    let nextTempId = 1;
    const groupMap = new Map<
      number,
      { groupId: number; dtos: MonthlyBudgetDetailedDto[] }
    >();

    for (const dto of dtos) {
      if (!groupMap.has(dto.group_id)) {
        groupMap.set(dto.group_id, { groupId: dto.group_id, dtos: [] });
      }
      groupMap.get(dto.group_id)!.dtos.push(dto);
    }

    const result: BudgetGroupRow[] = [];

    for (const { groupId, dtos: groupDtos } of groupMap.values()) {
      const categories: BudgetCategoryRow[] = [];

      for (const dto of groupDtos) {
        categories.push({
          tempId: nextTempId++,
          categoryId: dto.category_id,
          plannedAmount: dto.planned_amount,
          prevPlannedAmount: dto.previous_planned_amount,
          currentSpentAmount: dto.spent_amount,
          prevSpentAmount: dto.previous_spent_amount,
        });
      }

      if (categories.length === 0) continue;

      result.push({ tempId: nextTempId++, groupId, categories });
    }

    return result;
  }
}
