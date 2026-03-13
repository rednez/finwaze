import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';
import { BudgetGauge } from '@shared/ui/budget-gauge';
import { StyledAmount } from '@shared/ui/styled-amount';

@Component({
  selector: 'app-monthly-summary-card-gauge',
  imports: [BudgetGauge, StyledAmount],
  template: `
    <app-budget-gauge
      [totalAmount]="budgetAmount()"
      [spentAmount]="spentAmount()"
    />

    <div class="absolute bottom-2 left-1/2 -translate-x-1/2 text-center">
      <div class="text-gray-400 text-sm flex gap-1 justify-center">
        <span>{{ spentPercentage() }}%</span>
        <span>spent</span>
      </div>
      <app-styled-amount
        class="sm:hidden"
        [amount]="spentAmount()"
        [currency]="currency()"
        size="sm"
      />
      <app-styled-amount
        class="hidden sm:block"
        [amount]="spentAmount()"
        [currency]="currency()"
      />

      <div class="text-gray-400 text-sm flex gap-1 justify-center mt-3">
        <span>{{ leftPercentage() }}%</span>
        <span>left</span>
      </div>
      <app-styled-amount
        class="sm:hidden"
        [amount]="leftAmount()"
        [currency]="currency()"
        size="sm"
      />
      <app-styled-amount
        class="hidden sm:block"
        [amount]="leftAmount()"
        [currency]="currency()"
      />
    </div>
  `,
  host: {
    class: 'block relative',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MonthlySummaryCardGauge {
  readonly budgetAmount = input(0);
  readonly spentAmount = input(0);
  readonly currency = input.required<string>();

  protected readonly spentPercentage = computed(() =>
    Math.floor((this.spentAmount() / this.budgetAmount()) * 100),
  );

  protected readonly leftPercentage = computed(() =>
    Math.floor(
      ((this.budgetAmount() - this.spentAmount()) / this.budgetAmount()) * 100,
    ),
  );

  protected readonly leftAmount = computed(
    () => this.budgetAmount() - this.spentAmount(),
  );
}
