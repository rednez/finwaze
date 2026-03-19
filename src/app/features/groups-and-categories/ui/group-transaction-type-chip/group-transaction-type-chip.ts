import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';
import { TransactionType } from '@core/models/transactions';

@Component({
  selector: 'app-group-transaction-type-chip',
  imports: [],
  template: ` {{ transactionTypeText() }} `,
  styles: `
    @reference "tailwindcss";

    :host {
      @apply w-fit text-xs font-normal px-2 py-1 rounded-xl mt-1;
    }
  `,
  host: {
    '[class]': 'type() === "income" ? incomeClasses : expenseClasses',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GroupTransactionTypeChip {
  readonly type = input<TransactionType>();

  protected readonly transactionTypeText = computed(() =>
    this.type() === 'expense' ? 'Expense' : 'Income',
  );

  protected readonly incomeClasses =
    'text-green-500 dark:text-green-600 bg-green-100 dark:bg-gray-800';
  protected readonly expenseClasses =
    'text-orange-500 dark:text-orange-600 bg-orange-100 dark:bg-gray-800';
}
