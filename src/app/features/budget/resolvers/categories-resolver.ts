import { inject } from '@angular/core';
import { ResolveFn } from '@angular/router';
import { BudgetService } from '../services/budget.service';
import { BudgetState } from '../services/budget-state';
import { tap } from 'rxjs';

export const categoriesResolver: ResolveFn<
  Array<{
    id: number;
    name: string;
    budgetAmount: number;
    spentAmount: number;
    currency: string;
  }>
> = (route, state) => {
  const budgetService = inject(BudgetService);
  const budgetState = inject(BudgetState);
  const groupId = route.paramMap.get('id')!;

  budgetState.isLoadingCategories.set(true);

  return budgetService
    .getCategories(Number(groupId))
    .pipe(tap(() => budgetState.isLoadingCategories.set(false)));
};
