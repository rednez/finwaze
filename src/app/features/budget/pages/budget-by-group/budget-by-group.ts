import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { CategoryMonthlyBudget } from '../../models';
import { BudgetCard } from '../../ui/budget-card';
import { BudgetMostExpensesCard } from '../../ui/budget-most-expenses-card';
import { MonthlySummaryCard } from '../../ui/monthly-summary-card';

@Component({
  imports: [BudgetCard, MonthlySummaryCard, BudgetMostExpensesCard],
  templateUrl: './budget-by-group.html',
  host: {
    class: 'flex flex-col gap-4 md:flex-row md:flex-wrap',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetByGroup {
  // private readonly budgetState = inject(BudgetState);

  // protected readonly groupName = this.budgetState.selectedGroupName;

  readonly categories = input.required<CategoryMonthlyBudget[]>();

  readonly mostExpenses = input.required<
    {
      id: number;
      name: string;
      currentAmount: number;
      previousPeriodAmount: number;
      currency: string;
    }[]
  >();
}
