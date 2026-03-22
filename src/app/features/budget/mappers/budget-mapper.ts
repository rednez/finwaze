import { Injectable } from '@angular/core';
import {
  CategoryMonthlyBudget,
  CategoryMonthlyBudgetDto,
  GroupMonthlyBudget,
  GroupMonthlyBudgetDto,
  MonthlyBudgetTotals,
  MonthlyBudgetTotalsDto,
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
}
