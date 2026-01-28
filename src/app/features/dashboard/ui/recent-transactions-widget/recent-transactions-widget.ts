import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { Card } from '@ui/card';
import { TableModule } from 'primeng/table';

type RecentTransaction = {
  id: number;
  date: string;
  amount: number;
  currency: string;
  group: string;
  category: string;
};

@Component({
  selector: 'app-recent-transactions-widget',
  imports: [CommonModule, Card, TableModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-card>
      <div class="text-lg font-medium mb-4">Recent Transactions</div>

      <p-table [value]="transactions()" [tableStyle]="{ 'min-width': '30rem' }">
        <ng-template #header>
          <tr>
            <th>Date</th>
            <th>Amount</th>
            <th>Group</th>
            <th>Category</th>
          </tr>
        </ng-template>
        <ng-template #body let-transaction>
          <tr>
            <td>
              {{ transaction.date | date: 'dd.MM.yyyy' }}
            </td>
            <td>
              {{ transaction.amount | currency: transaction.currency }}
            </td>
            <td>{{ transaction.group }}</td>
            <td>{{ transaction.category }}</td>
          </tr>
        </ng-template>
      </p-table>
    </app-card>
  `,
  styles: `
    tr,
    td {
      font-size: 0.875rem;
    }
  `,
})
export class RecentTransactionsWidget {
  readonly transactions = input<RecentTransaction[]>([]);
}
