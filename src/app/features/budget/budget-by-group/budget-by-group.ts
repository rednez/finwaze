import {
  ChangeDetectionStrategy,
  Component,
  inject,
  input,
} from '@angular/core';
import { BudgetCard } from '../ui/budget-card/budget-card';
import { BudgetFilters } from '../ui/budget-filters/budget-filters';
import { BudgetMostExpensesCard } from '../ui/budget-most-expenses-card/budget-most-expenses-card';
import { MonthlySummaryCard } from '../ui/monthly-summary-card/monthly-summary-card';
import { BudgetState } from '../services/budget-state';

@Component({
  imports: [
    BudgetCard,
    BudgetFilters,
    MonthlySummaryCard,
    BudgetMostExpensesCard,
  ],
  templateUrl: './budget-by-group.html',
  host: {
    class: 'flex flex-col gap-4 md:flex-row md:flex-wrap',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetByGroup {
  private readonly budgetState = inject(BudgetState);

  protected readonly groupName = this.budgetState.selectedGroupName;

  readonly categories = input.required<
    Array<{
      id: number;
      name: string;
      budgetAmount: number;
      spentAmount: number;
      currency: string;
    }>
  >();

  readonly mostExpenses = input.required<
    Array<{
      id: number;
      name: string;
      currentAmount: number;
      previousPeriodAmount: number;
      currency: string;
    }>
  >();
}
