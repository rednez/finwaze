import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  input,
  output,
} from '@angular/core';
import { Transaction } from '@core/models/transactions';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import {
  TransactionDataTableColumnType,
  TransactionsDataTable,
} from '@shared/ui/transactions-data-table';
import { CardEmptyState } from '../card-empty-state';

@Component({
  selector: 'app-recent-transactions-widget',
  imports: [
    CommonModule,
    Card,
    CardHeader,
    CardHeaderTitle,
    TransactionsDataTable,
    CardEmptyState,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-card>
      <app-card-header>
        <app-card-header-title>Recent Transactions</app-card-header-title>
      </app-card-header>

      @if (transactions().length > 0) {
        <app-transactions-data-table
          [transactions]="transactions()"
          [cols]="tableCols"
          [shortDateFormat]="true"
          transactionAmountHeaderTitle="Amount"
        />
      } @else {
        <app-card-empty-state
          title="No transactions"
          actionText="You can add new transactions to see them here in the Transactions."
          actionBtnLabel="Goto Transactions"
          (actionBtnClicked)="actionClicked.emit()"
        />
      }
    </app-card>
  `,
})
export class RecentTransactionsWidget {
  readonly transactions = input<Transaction[]>([]);
  readonly actionClicked = output<void>();

  protected readonly tableCols: TransactionDataTableColumnType[] = [
    'date',
    'group',
    'category',
    'transactionAmount',
  ];
}
