import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';
import { TransactionType } from '@core/models/transactions';

@Component({
  selector: 'app-transaction-type-chip',
  template: ` <ng-content /> `,
  host: {
    class: 'block w-fit p-1 rounded-lg',
    '[class]':
      'isTransfer() ? transferClass : isExpense() ? expenseClass : isIncome() ? incomeClass : ""',
    '[class.text-xs]': 'isSmall()',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TransactionTypeChip {
  readonly type = input<TransactionType>();
  readonly isSmall = input(false);

  protected readonly isTransfer = computed(() => this.type() === 'transfer');
  protected readonly isExpense = computed(() => this.type() === 'expense');
  protected readonly isIncome = computed(() => this.type() === 'income');

  protected readonly transferClass =
    'bg-gray-100 text-gray-600 dark:bg-gray-800/50 dark:text-gray-300';
  protected readonly expenseClass =
    'bg-rose-50 text-rose-600 dark:bg-rose-800/50 dark:text-gray-300';
  protected readonly incomeClass =
    'bg-green-50 text-green-600 dark:bg-green-800/50 dark:text-gray-300';
}
