import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { Transaction } from '@core/models/transactions';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import {
  TransactionDataTableColumnType,
  TransactionsDataTable,
} from '@shared/ui/transactions-data-table';

@Component({
  selector: 'app-recent-transactions-widget',
  imports: [
    CommonModule,
    Card,
    CardHeader,
    CardHeaderTitle,
    TransactionsDataTable,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-card>
      <app-card-header>
        <app-card-header-title>Recent Transactions</app-card-header-title>
      </app-card-header>

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
