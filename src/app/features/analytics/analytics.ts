import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { Card } from '@shared/ui/card';
import { SkeletonModule } from 'primeng/skeleton';
import { AnalyticsStore } from './stores';
import { AnalyticStatisticsCard } from './ui/analytic-statistics-card';
import { BudgetsExpensesCard } from './ui/budget-expenses-card';
import { FinancialMonthlyOverviewCard } from './ui/financial-monthly-overview-card';
import { FinancialSummaryCard } from './ui/financial-summary-card';
import { StatsFilters } from './ui/stats-filters';

@Component({
  imports: [
    StatsFilters,
    FinancialSummaryCard,
    FinancialMonthlyOverviewCard,
    BudgetsExpensesCard,
    AnalyticStatisticsCard,
    SkeletonModule,
    Card,
  ],
  templateUrl: './analytics.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    class: 'flex flex-col gap-4',
  },
})
export class Analytics {
  protected readonly store = inject(AnalyticsStore);

  constructor() {
    if (this.store.isLoaded()) {
      this.store.loadFinancialSummary();
    }
  }
}
