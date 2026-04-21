import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { DatePickerModule } from 'primeng/datepicker';
import { BudgetsExpensesChart } from '../budgets-expenses-chart/budgets-expenses-chart';
import { BudgetsExpensesCardStore } from './budgets-expenses-card-store';

@Component({
  selector: 'app-budgets-expenses-card',
  providers: [BudgetsExpensesCardStore],
  imports: [
    Card,
    CardHeader,
    CardHeaderTitle,
    BudgetsExpensesChart,
    FormsModule,
    DatePickerModule,
    TranslatePipe,
  ],
  template: `
    <app-card>
      <app-card-header class="flex items-center justify-between">
        <app-card-header-title>
          {{ 'analytics.budgetsExpenses.title' | translate }}
        </app-card-header-title>

        <p-datepicker
          append-right
          [ngModel]="store.selectedYear()"
          (ngModelChange)="store.updateYear($event)"
          view="year"
          dateFormat="yy"
          [readonlyInput]="true"
          class="w-54"
          size="small"
          [inputStyle]="{ borderRadius: '12px' }"
        />
      </app-card-header>

      <app-budgets-expenses-chart
        [labels]="store.labels()"
        [expenses]="store.expenses()"
        [budgets]="store.budgets()"
      />
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetsExpensesCard {
  protected readonly store = inject(BudgetsExpensesCardStore);
}
