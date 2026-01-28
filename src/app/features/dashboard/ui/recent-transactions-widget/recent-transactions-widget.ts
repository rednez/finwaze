import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { Transaction } from '@models/transactions';
import { Card } from '@ui/card';
import {
  TransactionDataTableColumnType,
  TransactionsDataTable,
} from '@ui/transactions-data-table';

@Component({
  selector: 'app-recent-transactions-widget',
  imports: [CommonModule, Card, TransactionsDataTable],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-card>
      <div class="text-lg font-medium mb-4">Recent Transactions</div>

      <app-transactions-data-table
        [transactions]="transactions()"
        [cols]="tableCols"
        [shortDateFormat]="true"
        transactionAmountHeaderTitle="Amount"
      />
    </app-card>
  `,
})
export class RecentTransactionsWidget {
  readonly transactions = input<Transaction[]>([]);

  protected readonly tableCols: TransactionDataTableColumnType[] = [
    'date',
    'group',
    'category',
    'transactionAmount',
  ];
}
