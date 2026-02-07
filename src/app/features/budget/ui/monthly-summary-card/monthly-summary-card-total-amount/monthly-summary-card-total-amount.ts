import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { StyledAmount } from '@ui/styled-amount/styled-amount';
import { BudgetStatusBadge } from '../../budget-status-badge/budget-status-badge';

@Component({
  selector: 'app-monthly-summary-card-total-amount',
  imports: [CommonModule, StyledAmount, BudgetStatusBadge],
  template: `
    <div>
      <app-styled-amount
        class="hidden sm:block"
        size="lg"
        [amount]="budgetAmount()"
        [currency]="currency()"
      />
      <app-styled-amount
        class="sm:hidden"
        [amount]="budgetAmount()"
        [currency]="currency()"
      />
    </div>

    <app-budget-status-badge
      class="mt-1"
      [budgetAmount]="budgetAmount()"
      [spentAmount]="spentAmount()"
    />
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MonthlySummaryCardTotalAmount {
  readonly budgetAmount = input(0);
  readonly spentAmount = input(0);
  readonly currency = input.required<string>();
}
