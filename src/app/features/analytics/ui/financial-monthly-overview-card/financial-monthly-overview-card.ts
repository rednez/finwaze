import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  model,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { SelectModule } from 'primeng/select';
import { SkeletonModule } from 'primeng/skeleton';
import { AnalyticsStore } from '../../stores';
import { FinancialMonthlyOverviewChart } from '../financial-monthly-overview-chart/financial-monthly-overview-chart';

@Component({
  selector: 'app-financial-monthly-overview-card',
  imports: [
    Card,
    FinancialMonthlyOverviewChart,
    FormsModule,
    SelectModule,
    SkeletonModule,
    CardHeaderTitle,
    CardHeader,
  ],
  template: `
    <app-card>
      <app-card-header class="flex items-center justify-between">
        <app-card-header-title>Monthly overview</app-card-header-title>

        <p-select
          append-right
          [(ngModel)]="type"
          [options]="types()"
          optionLabel="name"
          size="small"
          [dt]="{
            root: {
              borderRadius: '12px',
            },
          }"
        />
      </app-card-header>

      <app-financial-monthly-overview-chart
        [labels]="labels()"
        [currentAmounts]="currentAmounts()"
        [previousAmounts]="previousAmounts()"
        labelFormat="d"
      />
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FinancialMonthlyOverviewCard {
  protected readonly store = inject(AnalyticsStore);

  protected readonly types = signal([
    { name: 'Total balance' },
    { name: 'Total income' },
    { name: 'Total expenses' },
  ]);

  protected type = model({ name: 'Total balance' });

  protected readonly labels = computed(() =>
    this.store.dailyOverview().map((d) => d.day),
  );

  protected readonly currentAmounts = computed(() => {
    const overview = this.store.dailyOverview();
    const typeName = this.type().name;
    if (typeName === 'Total balance')
      return overview.map((d) => d.runningBalance);
    if (typeName === 'Total income') return overview.map((d) => d.dailyIncome);
    return overview.map((d) => d.dailyExpense);
  });

  protected readonly previousAmounts = computed(() => {
    const overview = this.store.previousDailyOverview();
    const typeName = this.type().name;
    if (typeName === 'Total balance')
      return overview.map((d) => d.runningBalance);
    if (typeName === 'Total income') return overview.map((d) => d.dailyIncome);
    return overview.map((d) => d.dailyExpense);
  });
}
