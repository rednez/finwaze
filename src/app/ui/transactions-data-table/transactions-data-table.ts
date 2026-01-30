import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';
import { Transaction } from '@models/transactions';

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
  template: `
    <table class="text-sm w-full">
      <thead
        class="sticky top-0 bg-primary-100/80 dark:bg-gray-800 backdrop-blur-sm"
      >
        <tr>
          @for (
            header of headersTitles();
            track header;
            let first = $first;
            let last = $last
          ) {
            <th
              class="font-normal text-sm text-primary uppercase text-start"
              [class.rounded-s-3xl]="first"
              [class.pl-4!]="first"
              [class.rounded-e-3xl]="last"
            >
              {{ header }}
            </th>
          }
        </tr>
      </thead>
      <tbody>
        @for (row of transactions(); track row.id) {
          <tr class="border-b border-gray-200 dark:border-gray-700">
            @if (hasDateColumn()) {
              <td
                class="pl-4! pr-1 text-xs lg:text-sm text-muted-color sm:whitespace-nowrap"
              >
                <span class="sm:hidden">
                  {{ row.createdAt | date: 'dd.MM.yyyy' }}
                </span>
                <span class="hidden sm:block">
                  {{ row.createdAt | date: dateFormat() }}
                </span>
              </td>
            }
            @if (hasGroupColumn()) {
              <td>
                {{ row.group }}
              </td>
            }
            @if (hasCategoryColumn()) {
              <td>{{ row.category }}</td>
            }
            @if (hasTransactionAmountColumn()) {
              <td>
                {{ row.transactionAmount | currency: row.transactionCurrency }}
              </td>
            }
            @if (hasChargedAmountColumn()) {
              <td>
                {{ row.chargedAmount | currency: row.chargedCurrency }}
              </td>
            }
            @if (hasExchangeRateColumn()) {
              <td class="text-muted-color">
                {{ row.exchangeRate | number: '1.4-4' }}
              </td>
            }
            @if (hasCommentColumn()) {
              <td class="text-muted-color min-w-60">
                {{ row.comment || '–' }}
              </td>
            }
          </tr>
        }
      </tbody>
    </table>
  `,
  styles: `
    @reference "tailwindcss";

    th {
      @apply px-1 sm:px-2 py-4;
    }

    td {
      @apply px-1 sm:px-2 py-3;
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

  protected readonly dateFormat = computed(() =>
    this.shortDateFormat() ? 'dd.MM.yyyy' : 'dd.MM.yyyy, HH:mm',
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
