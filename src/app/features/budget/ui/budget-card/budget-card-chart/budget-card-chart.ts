import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { DonutBudgetSpentChart } from '../../donut-budget-spent-chart/donut-budget-spent-chart';

@Component({
  selector: 'app-budget-card-chart',
  imports: [DonutBudgetSpentChart],
  template: `
    <app-donut-budget-spent-chart
      [budgetAmount]="budgetAmount()"
      [spentAmount]="spentAmount()"
      [currency]="currency()"
      radiusSize="sm"
      class="sm:hidden"
    />
    <app-donut-budget-spent-chart
      [budgetAmount]="budgetAmount()"
      [spentAmount]="spentAmount()"
      [currency]="currency()"
      radiusSize="md"
      class="hidden sm:block"
    />
  `,
  styles: ``,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetCardChart {
  readonly budgetAmount = input(0);
  readonly spentAmount = input(0);
  readonly currency = input.required<string>();
}
