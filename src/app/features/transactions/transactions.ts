import {
  ChangeDetectionStrategy,
  Component,
  inject,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import {
  TransactionDataTableColumnType,
  TransactionsDataTable,
} from '@shared/ui/transactions-data-table';
import { ButtonModule } from 'primeng/button';
import { DatePickerModule } from 'primeng/datepicker';
import { IftaLabelModule } from 'primeng/iftalabel';
import { SelectModule } from 'primeng/select';
import { TableModule } from 'primeng/table';
import { TransactionsStore } from './store/transactions-store';
import { TransactionsFilters } from './ui/transactions-filters/transactions-filters';

@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    FormsModule,
    TableModule,
    TransactionsDataTable,
    SelectModule,
    IftaLabelModule,
    DatePickerModule,
    TransactionsFilters,
    ButtonModule,
  ],
  templateUrl: './transactions.html',
  styleUrls: ['./transactions.css'],
})
export class Transactions {
  protected readonly store = inject(TransactionsStore);

  protected readonly tableCols: TransactionDataTableColumnType[] = [
    'date',
    'group',
    'category',
    'transactionAmount',
    'chargedAmount',
    'exchangeRate',
    'comment',
  ];

  constructor() {
    if (!this.store.isLoaded()) {
      this.store.loadTransactions();
    }
  }

  onMonthChanged(event: Date) {
    this.store.updateMonth(event);
    this.store.loadTransactions();
  }

  onCurrencyChanged(event: string | null) {
    this.store.updateCurrency(event);
    this.store.loadTransactions();
  }

  onGroupChanged(event: number | null) {
    this.store.updateGroup(event);
    this.store.loadTransactions();
  }

  onCategoryChanged(event: number | null) {
    this.store.updateCategory(event);
    this.store.loadTransactions();
  }
}
