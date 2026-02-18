import {
  ChangeDetectionStrategy,
  Component,
  model,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { SelectModule } from 'primeng/select';
import { FinancialMonthlyOverviewChart } from '../financial-monthly-overview-chart/financial-monthly-overview-chart';

@Component({
  selector: 'app-financial-monthly-overview-card',
  imports: [
    Card,
    FinancialMonthlyOverviewChart,
    FormsModule,
    SelectModule,
    CardHeaderTitle,
    CardHeader,
  ],
  template: `
    <app-card>
      <app-card-header class="flex items-center justify-between">
        <app-card-header-title>Total balance overview</app-card-header-title>

        <p-select
          append-right
          [(ngModel)]="type"
          [options]="types()"
          optionLabel="name"
          class="pt-1"
          size="small"
          [dt]="{
            root: {
              borderRadius: '16px',
            },
          }"
        />
      </app-card-header>

      <app-financial-monthly-overview-chart
        [labels]="labels"
        [currentAmounts]="currentAmounts"
        [previousAmounts]="previousAmounts"
      />
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FinancialMonthlyOverviewCard {
  labels = [
    '2025-01-01',
    '2025-02-01',
    '2025-03-01',
    '2025-04-01',
    '2025-05-01',
    '2025-06-01',
    '2025-07-01',
    '2025-08-01',
    '2025-09-01',
    '2025-10-01',
    '2025-11-01',
    '2025-12-01',
  ];

  currentAmounts = [1200, 0, 3200, 500, 5000, 1800, 1200, 1200, 0, 1300, 0, 0];
  previousAmounts = [1000, 0, 0, 1000, 790, 800, 1100, 0, 0, 300, 0, 0];

  protected readonly types = signal([
    { name: 'Total balance' },
    { name: 'Total income' },
    { name: 'Total expenses' },
  ]);

  protected type: { name: string } = model({ name: 'Total balance' });
}
