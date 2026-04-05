import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { DonutBudgetSpentChart } from '../../donut-budget-spent-chart/donut-budget-spent-chart';

@Component({
  selector: 'app-budget-card-chart',
  imports: [DonutBudgetSpentChart],
  template: `
    <app-donut-budget-spent-chart
      [plannedAmount]="plannedAmount()"
      [spentAmount]="spentAmount()"
      [currency]="currency()"
      radiusSize="sm"
      class="sm:hidden"
    />
    <app-donut-budget-spent-chart
      [plannedAmount]="plannedAmount()"
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
  readonly plannedAmount = input(0);
  readonly spentAmount = input(0);
  readonly currency = input<string>();
}
