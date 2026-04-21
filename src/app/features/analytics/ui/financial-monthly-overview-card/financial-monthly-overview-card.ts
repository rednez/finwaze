import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  model,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { LocalizationService } from '@core/services/localization.service';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { SelectModule } from 'primeng/select';
import { SkeletonModule } from 'primeng/skeleton';
import { AnalyticsStore } from '../../stores';
import { FinancialMonthlyOverviewChart } from '../financial-monthly-overview-chart/financial-monthly-overview-chart';

type OverviewType = 'balance' | 'income' | 'expenses';

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
    TranslatePipe,
  ],
  template: `
    <app-card>
      <app-card-header class="flex items-center justify-between">
        <app-card-header-title>{{
          'analytics.monthlyOverview.title' | translate
        }}</app-card-header-title>

        <p-select
          append-right
          [ngModel]="typeKey()"
          (ngModelChange)="typeKey.set($event)"
          [options]="types()"
          optionLabel="name"
          optionValue="value"
          size="small"
          [dt]="{ root: { borderRadius: '12px' } }"
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
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  protected readonly store = inject(AnalyticsStore);
  protected readonly typeKey = model<OverviewType>('balance');

  protected readonly types = computed(() => [
    {
      value: 'balance' as OverviewType,
      name: this.t('analytics.monthlyOverview.totalBalance'),
    },
    {
      value: 'income' as OverviewType,
      name: this.t('analytics.monthlyOverview.totalIncome'),
    },
    {
      value: 'expenses' as OverviewType,
      name: this.t('analytics.monthlyOverview.totalExpenses'),
    },
  ]);

  protected readonly labels = computed(() =>
    this.store.dailyOverview().map((d) => d.day),
  );

  protected readonly currentAmounts = computed(() => {
    const overview = this.store.dailyOverview();
    const key = this.typeKey();
    if (key === 'balance') return overview.map((d) => d.runningBalance);
    if (key === 'income') return overview.map((d) => d.dailyIncome);
    return overview.map((d) => d.dailyExpense);
  });

  protected readonly previousAmounts = computed(() => {
    const overview = this.store.previousDailyOverview();
    const key = this.typeKey();
    if (key === 'balance') return overview.map((d) => d.runningBalance);
    if (key === 'income') return overview.map((d) => d.dailyIncome);
    return overview.map((d) => d.dailyExpense);
  });
}
