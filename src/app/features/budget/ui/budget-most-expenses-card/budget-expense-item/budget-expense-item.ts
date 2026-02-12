import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { FinancialTrendBadge } from '@shared/ui/financial-trend-badge';

@Component({
  selector: 'app-budget-expense-item',
  imports: [CommonModule, FinancialTrendBadge],
  template: `
    <div>
      <div class="font-medium">
        {{ currentAmount() | currency: currency() }}
      </div>
      <div class="text-sm text-muted-color">{{ name() }}</div>
    </div>

    <app-financial-trend-badge
      [currentAmount]="currentAmount()"
      [previousAmount]="previousPeriodAmount()"
    />
  `,
  host: {
    class: 'flex items-center justify-between',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetExpenseItem {
  readonly name = input.required<string>();
  readonly currentAmount = input(0);
  readonly previousPeriodAmount = input(0);
  readonly currency = input.required<string>();
}
