import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { BudgetExpenseItem } from './budget-expense-item/budget-expense-item';

@Component({
  selector: 'app-budget-most-expenses-card',
  imports: [Card, CardHeader, CardHeaderTitle, BudgetExpenseItem],
  template: `
    <app-card>
      <app-card-header class="flex gap-2 justify-between">
        <app-card-header-title>Most expenses</app-card-header-title>
      </app-card-header>

      <div class="flex flex-col gap-2">
        @for (expense of expenses(); track expense.id) {
          <app-budget-expense-item
            [name]="expense.name"
            [currentAmount]="expense.currentAmount"
            [previousPeriodAmount]="expense.previousPeriodAmount"
            [currency]="expense.currency"
          />
        }
      </div>
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetMostExpensesCard {
  readonly expenses = input<
    Array<{
      id: number;
      name: string;
      currentAmount: number;
      previousPeriodAmount: number;
      currency: string;
    }>
  >([]);
}
