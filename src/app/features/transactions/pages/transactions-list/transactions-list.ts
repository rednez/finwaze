import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { EmptyState } from '@shared/ui/empty-state';
import {
  TransactionDataTableColumnType,
  TransactionsDataTable,
} from '@shared/ui/transactions-data-table';
import { ButtonModule } from 'primeng/button';
import { DatePickerModule } from 'primeng/datepicker';
import { IftaLabelModule } from 'primeng/iftalabel';
import { SelectModule } from 'primeng/select';
import { TableModule } from 'primeng/table';
import { SelectedTransactionStore, TransactionsStore } from '../../store';
import { TransactionsFilters } from '../../ui/transactions-filters/transactions-filters';

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
    EmptyState,
    TranslatePipe,
  ],
  templateUrl: './transactions-list.html',
  styleUrls: ['./transactions-list.css'],
})
export class TransactionsList {
  protected readonly store = inject(TransactionsStore);
  protected readonly selectedTransactionStore = inject(
    SelectedTransactionStore,
  );
  private readonly router = inject(Router);

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
    this.store.loadTransactions();
  }

  protected onMonthChanged(event: Date) {
    this.store.updateMonth(event);
    this.store.loadTransactions();
  }

  protected onTransactionTypeChanged(event: string | null) {
    this.store.updateTransactionType(event);
    this.store.loadTransactions();
  }

  protected onCurrencyChanged(event: string | null) {
    this.store.updateCurrency(event);
    this.store.loadTransactions();
  }

  protected onGroupChanged(event: number | null) {
    this.store.updateGroup(event);
    this.store.loadTransactions();
  }

  protected onCategoryChanged(event: number | null) {
    this.store.updateCategory(event);
    this.store.loadTransactions();
  }

  protected onClickTransaction($event: number) {
    const transaction = this.store.transactions().find((t) => t.id === $event);

    if (transaction) {
      if (transaction.type === 'transfer') {
        this.router.navigate(['transactions', 'transfer', $event]);
      } else {
        this.selectedTransactionStore.updateTransaction(transaction);
        this.router.navigate(['transactions', $event]);
      }
    }
  }

  protected gotoCreate() {
    this.router.navigate(['transactions', 'create']);
  }
}
