import { inject } from '@angular/core';
import { ResolveFn } from '@angular/router';
import { BudgetService } from '../services/budget.service';

export const mostExpensesResolver: ResolveFn<
  Array<{
    id: number;
    name: string;
    currentAmount: number;
    previousPeriodAmount: number;
    currency: string;
  }>
> = (route, state) => {
  const budgetService = inject(BudgetService);
  return budgetService.getMostExpenses();
};
