import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  inject,
  signal,
} from '@angular/core';
import { AppStore } from '@store/app-store';
import {
  TransactionDataTableColumnType,
  TransactionsDataTable,
} from '@ui/transactions-data-table';
import { TableModule } from 'primeng/table';

@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [CommonModule, TableModule, TransactionsDataTable],
  template: `
    <div class="scrollable-container overflow-auto max-h-[calc(100vh-100px)]">
      <app-transactions-data-table
        [transactions]="store.transactions()"
        [cols]="tableCols"
      />
    </div>
  `,
  styles: `
    .scrollable-container {
      scrollbar-width: thin;
      transition: scrollbar-color 200ms ease-out;
      scrollbar-color: var(--p-surface-400) transparent;

      &::-webkit-scrollbar {
        width: 8px;
        height: 8px;
      }

      &::-webkit-scrollbar-thumb {
        scrollbar-color: var(--p-surface-400) transparent;
        border-radius: 4px;
      }

      &:hover::-webkit-scrollbar-thumb,
      &:active::-webkit-scrollbar-thumb {
        background-color: var(--p-surface-400);
      }
    }
  `,
})
export class Transactions {
  protected readonly store = inject(AppStore);

  protected readonly tableCols: TransactionDataTableColumnType[] = [
    'date',
    'group',
    'category',
    'transactionAmount',
    'chargedAmount',
    'exchangeRate',
    'description',
  ];
}
