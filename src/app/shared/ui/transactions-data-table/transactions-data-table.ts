import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
  output,
} from '@angular/core';
import { Transaction } from '@core/models/transactions';

export type TransactionDataTableColumnType =
  | 'date'
  | 'group'
  | 'category'
  | 'transactionAmount'
  | 'chargedAmount'
  | 'exchangeRate'
  | 'comment';

@Component({
  selector: 'app-transactions-data-table',
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './transactions-data-table.html',
  styles: `
    @reference "tailwindcss";

    th {
      @apply px-1 sm:px-2 py-4;
    }

    td {
      @apply px-1 sm:px-2 py-3;
    }

    .hoverable:hover {
      @apply hover:bg-gray-50 dark:hover:bg-gray-900;
    }

    .chip {
      @apply p-1 rounded-lg;

      &.transfer {
        @apply bg-gray-100 text-gray-600 dark:bg-gray-800/50 dark:text-gray-300;
      }
      &.expense {
        @apply bg-rose-50 text-rose-600 dark:bg-rose-800/50 dark:text-gray-300;
      }
      &.income {
        @apply bg-green-50 text-green-600 dark:bg-green-800/50 dark:text-gray-300;
      }
      &.small {
        @apply text-xs;
      }
    }
  `,
})
export class TransactionsDataTable {
  readonly transactions = input<Transaction[]>([]);
  readonly transactionAmountHeaderTitle = input<string>();
  readonly cols = input<TransactionDataTableColumnType[]>([
    'transactionAmount',
  ]);
  readonly shortDateFormat = input(false);
  readonly isHoverable = input(false);
  readonly rowClicked = output<number>();

  protected readonly dateFormat = computed(() =>
    this.shortDateFormat() ? 'shortDate' : 'short',
  );

  protected readonly headersTitles = computed(() =>
    this.cols().map((i) => {
      switch (i) {
        case 'date':
          return 'Date';
        case 'group':
          return 'Group';
        case 'category':
          return 'Category';
        case 'transactionAmount':
          return this.transactionAmountHeaderTitle() || 'Transaction Amount';
        case 'chargedAmount':
          return 'Charged Amount';
        case 'exchangeRate':
          return 'Exchange Rate';
        case 'comment':
          return 'Comment';
        default:
          return '';
      }
    }),
  );

  protected readonly hasDateColumn = computed(() =>
    this.cols().includes('date'),
  );

  protected readonly hasGroupColumn = computed(() =>
    this.cols().includes('group'),
  );

  protected readonly hasCategoryColumn = computed(() =>
    this.cols().includes('category'),
  );

  protected readonly hasTransactionAmountColumn = computed(() =>
    this.cols().includes('transactionAmount'),
  );

  protected readonly hasChargedAmountColumn = computed(() =>
    this.cols().includes('chargedAmount'),
  );

  protected readonly hasExchangeRateColumn = computed(() =>
    this.cols().includes('exchangeRate'),
  );

  protected readonly hasCommentColumn = computed(() =>
    this.cols().includes('comment'),
  );
}
