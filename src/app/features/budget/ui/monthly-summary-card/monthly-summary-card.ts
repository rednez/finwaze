import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { Card } from '@shared/ui/card/card';
import { MonthlySummaryCardGauge } from './monthly-summary-card-gauge/monthly-summary-card-gauge';
import { MonthlySummaryCardTotalAmount } from './monthly-summary-card-total-amount/monthly-summary-card-total-amount';

@Component({
  selector: 'app-monthly-summary-card',
  imports: [
    Card,
    CardHeader,
    CardHeaderTitle,
    MonthlySummaryCardTotalAmount,
    MonthlySummaryCardGauge,
  ],
  template: `
    <app-card>
      <app-card-header class="flex gap-2 justify-between">
        <app-card-header-title>{{ name() }}</app-card-header-title>
      </app-card-header>

      <app-monthly-summary-card-total-amount
        [budgetAmount]="budgetAmount()"
        [spentAmount]="spentAmount()"
        [currency]="currency()"
      />

      <app-monthly-summary-card-gauge
        class="min-w-62 max-w-85 md:w-85 m-auto"
        [budgetAmount]="budgetAmount()"
        [spentAmount]="spentAmount()"
        [currency]="currency()"
      />
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MonthlySummaryCard {
  readonly name = input('');
  readonly budgetAmount = input(0);
  readonly spentAmount = input(0);
  readonly currency = input.required<string>();
}
