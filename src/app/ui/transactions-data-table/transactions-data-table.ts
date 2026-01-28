import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { Transaction } from '@models/transactions';

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
            header of headers;
            track header;
            let first = $first;
            let last = $last
          ) {
            <th
              class="font-medium text-xs text-primary uppercase text-start"
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
            <td
              class="pl-4! pr-1 text-xs lg:text-sm text-muted-color sm:whitespace-nowrap"
            >
              {{ row.date | date: 'dd.MM.yyyy, HH:mm' }}
            </td>
            <td>
              {{ row.group }}
            </td>
            <td>{{ row.category }}</td>
            <td>
              {{ row.transactionAmount | currency: row.transactionCurrency }}
            </td>
            <td>
              {{ row.chargedAmount | currency: row.chargedCurrency }}
            </td>
            <td class="text-muted-color">
              {{ row.exchangeRate | number: '1.4-4' }}
            </td>
            <td class="text-muted-color min-w-60">{{ row.description }}</td>
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

  protected readonly headers = [
    'Date',
    'Group',
    'Category',
    'Transaction Amount',
    'Charged Amount',
    'Exchange Rate',
    'Description',
  ];
}
