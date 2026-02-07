import { inject } from '@angular/core';
import { CanActivateFn, RedirectCommand, Router } from '@angular/router';
import { BudgetState } from '../services/budget-state';

export const budgetByGroupGuard: CanActivateFn = (route, state) => {
  const budgetState = inject(BudgetState);
  const router = inject(Router);

  if (!budgetState.selectedCurrency() || !budgetState.selectedGroupName()) {
    return new RedirectCommand(router.parseUrl('/budget'));
  } else {
    return true;
  }
};
