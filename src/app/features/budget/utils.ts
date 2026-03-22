import { BudgetStatus } from './models';

export function getBudgetStatus(
  plannedAmount: number,
  spentAmount: number,
): BudgetStatus {
  const leftPercentage = 100 - (spentAmount / plannedAmount) * 100;

  return leftPercentage >= 20
    ? 'onTrack'
    : leftPercentage < 20 && leftPercentage >= 0
      ? 'attention'
      : 'overBudget';
}
