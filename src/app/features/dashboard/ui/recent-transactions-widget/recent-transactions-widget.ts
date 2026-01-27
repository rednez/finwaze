import { CommonModule } from '@angular/common';
import { Component, signal } from '@angular/core';
import { Card } from '@ui/card';
import { TableModule } from 'primeng/table';

@Component({
  selector: 'app-recent-transactions-widget',
  imports: [CommonModule, Card, TableModule],
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
              {{ transaction.date | date: 'dd.MM.yyyy, HH:mm' }}
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
  protected transactions = signal([
    {
      id: 1,
      date: '2024-06-01T12:34:56',
      amount: 122354.23,
      currency: '$',
      group: 'Life',
      category: 'Products',
      description: 'Grocery Store',
      exchangeAmount: 12.2,
      exchangeCurrency: '€',
      exchangeRate: 0.225,
    },
    {
      id: 2,
      date: '2024-06-02T08:15:30',
      amount: 3120.0,
      currency: '$',
      group: 'Transport',
      category: 'Fuel',
      description: 'Gas Station',
      exchangeAmount: 27.0,
      exchangeCurrency: '€',
      exchangeRate: 0.225,
    },
    {
      id: 3,
      date: '2025-09-12T14:20:00',
      amount: 12.0,
      currency: '$',
      group: 'Transport',
      category: 'Fuel',
      description: 'Gas Station',
      exchangeAmount: 27.0,
      exchangeCurrency: '€',
      exchangeRate: 0.225,
    },
  ]);
}
