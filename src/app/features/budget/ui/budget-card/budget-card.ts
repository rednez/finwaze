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
        <div append-right>
          <ng-content select="[card-actions]" />
        </div>
      </app-card-header>

      <div class="flex gap-4 items-end">
        <app-budget-card-chart
          [plannedAmount]="plannedAmount()"
          [spentAmount]="spentAmount()"
          [currency]="currencyCode()"
        />

        <app-budget-card-summary
          [plannedAmount]="plannedAmount()"
          [spentAmount]="spentAmount()"
          [currency]="currencyCode()"
        />
      </div>
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetCard {
  readonly name = input('');
  readonly plannedAmount = input(0);
  readonly spentAmount = input(0);
  readonly currencyCode = input<string>();
}
