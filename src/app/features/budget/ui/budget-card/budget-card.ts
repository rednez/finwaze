import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { ButtonModule } from 'primeng/button';
import { BudgetCardChart } from './budget-card-chart/budget-card-chart';
import { BudgetCardSummary } from './budget-card-summary/budget-card-summary';

@Component({
  selector: 'app-budget-card',
  imports: [
    Card,
    CardHeader,
    CardHeaderTitle,
    ButtonModule,
    BudgetCardChart,
    BudgetCardSummary,
  ],
  template: `
    <app-card>
      <app-card-header class="flex gap-2 justify-between">
        <app-card-header-title>{{ name() }}</app-card-header-title>
        <div>
          <ng-content select="[card-actions]" />
        </div>
      </app-card-header>

      <div class="flex gap-4 items-end">
        <app-budget-card-chart
          [budgetAmount]="budgetAmount()"
          [spentAmount]="spentAmount()"
          [currency]="currency()"
        />

        <app-budget-card-summary
          [budgetAmount]="budgetAmount()"
          [spentAmount]="spentAmount()"
          [currency]="currency()"
        />
      </div>
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetCard {
  readonly name = input('');
  readonly budgetAmount = input(0);
  readonly spentAmount = input(0);
  readonly currency = input.required<string>();
}
