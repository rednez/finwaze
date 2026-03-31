import { CurrencyPipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'app-create-budget-totals',
  imports: [CurrencyPipe],
  template: `
    <span class="text-sm font-semibold">Загалом</span>
    <span class="text-right text-sm font-bold">
      {{ totalPlanned() | currency: currencyCode() : 'symbol' : '1.0-0' }}
    </span>
    <span class="text-right text-sm opacity-60">
      {{ totalPrevPlanned() | currency: currencyCode() : 'symbol' : '1.0-0' }}
    </span>
    <span class="text-right text-sm font-bold">
      {{ totalSpent() | currency: currencyCode() : 'symbol' : '1.0-0' }}
    </span>
    <span class="text-right text-sm opacity-60">
      {{ totalPrevSpent() | currency: currencyCode() : 'symbol' : '1.0-0' }}
    </span>
    <span></span>
  `,
  host: {
    class:
      'grid grid-cols-[1fr_repeat(4,minmax(110px,130px))_40px] gap-2 items-center px-4 py-4 rounded-2xl bg-surface-200 dark:bg-surface-800 text-surface-600 dark:text-surface-200 mt-2',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CreateBudgetTotals {
  readonly totalPlanned = input(0);
  readonly totalPrevPlanned = input(0);
  readonly totalSpent = input(0);
  readonly totalPrevSpent = input(0);
  readonly currencyCode = input('');
}
