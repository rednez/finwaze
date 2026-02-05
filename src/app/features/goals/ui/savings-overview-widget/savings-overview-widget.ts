import {
  ChangeDetectionStrategy,
  Component,
  model,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Card } from '@ui/card';
import { CardHeaderTitle } from '@ui/card-header-title/card-header-title';
import { CardHeader } from '@ui/card-header/card-header';
import { DatePickerModule } from 'primeng/datepicker';
import { IftaLabelModule } from 'primeng/iftalabel';
import { SelectModule } from 'primeng/select';
import { TableModule } from 'primeng/table';
import { SavingsOverviewChart } from '../savings-overview-chart/savings-overview-chart';

@Component({
  selector: 'app-savings-overview-widget',
  imports: [
    Card,
    SavingsOverviewChart,
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
        <app-card-header-title>Savings overview</app-card-header-title>

        <div class="flex gap-2">
          <p-datepicker
            [(ngModel)]="date"
            view="year"
            dateFormat="yy"
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

      <app-savings-overview-chart
        [labels]="labels"
        [currentSavings]="currentSavings"
        [previousSavings]="previousSavings"
      />
    </app-card>
  `,
  styles: ``,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SavingsOverviewWidget {
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

  currentSavings = [1200, 0, 3200, 500, 5000, 1800, 1200, 1200, 0, 1300, 0, 0];

  previousSavings = [1000, 0, 0, 1000, 790, 800, 1100, 0, 0, 300, 0, 0];

  protected readonly currencies = signal([
    { name: 'USD' },
    { name: 'EUR' },
    { name: 'UAH' },
  ]);

  protected date = model(new Date());
  protected currency?: { name: string } = model({ name: 'USD' });
}
