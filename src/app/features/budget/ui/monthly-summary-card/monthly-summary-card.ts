import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { CardEmptyState } from '@shared/ui/card-empty-state';
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
    CardEmptyState,
  ],
  template: `
    <app-card>
      <app-card-header class="flex gap-2 justify-between">
        <app-card-header-title>{{ name() }}</app-card-header-title>
      </app-card-header>

      @if (plannedAmount() > 0) {
        <app-monthly-summary-card-total-amount
          [plannedAmount]="plannedAmount()"
          [spentAmount]="spentAmount()"
          [currency]="currency()"
        />

        <app-monthly-summary-card-gauge
          class="min-w-62 max-w-85 md:w-85 m-auto"
          [plannedAmount]="plannedAmount()"
          [spentAmount]="spentAmount()"
          [currency]="currency()"
        />
      } @else {
        <app-card-empty-state
          title="No budgets for this month for selected currency"
          actionBtnLabel="Create budget"
        />
      }
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MonthlySummaryCard {
  readonly name = input('');
  readonly plannedAmount = input(0);
  readonly spentAmount = input(0);
  readonly currency = input<string>();
}
