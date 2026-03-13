import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';
import { StyledAmount } from '@shared/ui/styled-amount/styled-amount';
import { BudgetStatusBadge } from '../../budget-status-badge/budget-status-badge';

@Component({
  selector: 'app-budget-card-summary',
  imports: [CommonModule, StyledAmount, BudgetStatusBadge],
  template: `
    <div>
      <div class="text-muted-color">Left</div>
      <div class="flex flex-col">
        <!-- amount size depends on the screen size -->
        <app-styled-amount
          class="sm:hidden max-[500px]:max-w-36  overflow-hidden overflow-ellipsis"
          [amount]="leftAmount()"
          [currency]="currency()"
          size="sm"
        />
        <app-styled-amount
          class="hidden sm:block"
          [amount]="leftAmount()"
          [currency]="currency()"
        />

        <div class="text-primary-500 font-medium text-sm">
          <span>/</span>
          <span>{{
            budgetAmount() | currency: currency() : undefined : '1.0-0'
          }}</span>
        </div>
      </div>
    </div>

    <app-budget-status-badge
      [budgetAmount]="budgetAmount()"
      [spentAmount]="spentAmount()"
    />
  `,
  host: {
    class: 'flex flex-col gap-4',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetCardSummary {
  readonly budgetAmount = input(0);
  readonly spentAmount = input(0);
  readonly currency = input.required<string>();

  protected readonly leftAmount = computed(
    () => this.budgetAmount() - this.spentAmount(),
  );
}
