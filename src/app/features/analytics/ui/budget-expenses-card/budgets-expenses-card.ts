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
import { BudgetsExpensesChart } from '../budgets-expenses-chart/budgets-expenses-chart';

@Component({
  selector: 'app-budgets-expenses-card',
  imports: [
    Card,
    CardHeader,
    CardHeaderTitle,
    BudgetsExpensesChart,
    FormsModule,
    DatePickerModule,
  ],
  template: `
    <app-card>
      <app-card-header class="flex items-center justify-between">
        <app-card-header-title>Budgets vs Expenses</app-card-header-title>

        <p-datepicker
          [(ngModel)]="year"
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
      </app-card-header>

      <app-budgets-expenses-chart
        [labels]="labels()"
        [expenses]="expenses()"
        [budgets]="budgets()"
      />
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetsExpensesCard {
  labels = signal([
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
  ]);

  expenses = signal([
    1102, 1760, 1300, 1930, 1650, 1900, 1790, 2000, 2100, 1950, 1800, 2200,
    1980,
  ]);

  budgets = signal([
    1200, 1800, 1720, 2100, 1500, 1900, 1820, 2000, 2200, 2000, 1900, 2300,
  ]);

  year = model(new Date());
}
