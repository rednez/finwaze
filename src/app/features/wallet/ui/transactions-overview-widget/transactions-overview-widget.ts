import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { DatePickerModule } from 'primeng/datepicker';
import { IftaLabelModule } from 'primeng/iftalabel';
import { SelectModule } from 'primeng/select';
import { TableModule } from 'primeng/table';
import { TransactionsOverviewChart } from '../transactions-overview-chart/transactions-overview-chart';

@Component({
  selector: 'app-transactions-overview-widget',
  imports: [
    Card,
    TransactionsOverviewChart,
    FormsModule,
    TableModule,
    SelectModule,
    IftaLabelModule,
    DatePickerModule,
    CardHeaderTitle,
    CardHeader,
  ],
  template: `
    <app-card>
      <app-card-header class="flex items-center justify-between">
        <app-card-header-title>Transactions overflow</app-card-header-title>

        <div class="flex gap-2">
          <p-datepicker
            [(ngModel)]="date"
            view="month"
            dateFormat="mm/yy"
            [readonlyInput]="true"
            class="w-22"
            [inputStyle]="{
              borderRadius: '16px',
              fontSize: '14px',
              height: '42px',
            }"
          />

          <p-select
            [(ngModel)]="currency"
            [options]="currencies()"
            optionLabel="name"
            class="pt-1"
            size="small"
            [dt]="{
              root: {
                borderRadius: '16px',
              },
            }"
          />
        </div>
      </app-card-header>

      <app-transactions-overview-chart
        [labels]="labels"
        [incomes]="incomes"
        [expenses]="expenses"
      />
    </app-card>
  `,
  styles: ``,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TransactionsOverviewWidget {
  labels = [
    '2025-01-01',
    '2025-01-02',
    '2025-01-03',
    '2025-01-04',
    '2025-01-05',
    '2025-01-06',
    '2025-01-07',
    '2025-01-08',
    '2025-01-09',
    '2025-01-10',
    '2025-01-11',
    '2025-01-12',
    '2025-01-13',
    '2025-01-14',
    '2025-01-15',
    '2025-01-16',
    '2025-01-17',
    '2025-01-18',
    '2025-01-19',
    '2025-01-20',
    '2025-01-21',
    '2025-01-22',
    '2025-01-23',
    '2025-01-24',
    '2025-01-25',
    '2025-01-26',
    '2025-01-27',
    '2025-01-28',
    '2025-01-29',
    '2025-01-30',
    '2025-01-31',
  ];

  incomes = [
    1200, 1800, 3720, 2100, 1500, 1900, 1820, 4200, 2000, 2300, 2500, 2400,
    2600, 2700, 3000, 3200, 3100, 3300, 3400, 2100, 2300, 3000, 3100, 4100,
    1800, 3900, 1900, 2600, 3800, 3200, 2800,
  ];

  expenses = [
    1000, 900, 2700, 1900, 2100, 4000, 1920, 2000, 1700, 2000, 2950, 1000, 800,
    2000, 3000, 3000, 1100, 1100, 1200, 1970, 2900, 3100, 1200, 4100, 1830,
    1900, 2900, 1600, 1800, 1200, 2800,
  ];

  protected readonly currencies = signal([
    { name: 'USD' },
    { name: 'EUR' },
    { name: 'UAH' },
  ]);

  protected date = new Date();
  protected currency?: { name: string } = { name: 'USD' };
}
