import { CommonModule, DatePipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { generateAnalogColors } from '@core/utils/colors';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { DonutSummaryChart } from '@shared/ui/donut-summary-chart';
import { SelectModule } from 'primeng/select';
import { SelectButtonModule } from 'primeng/selectbutton';
import { SkeletonModule } from 'primeng/skeleton';
import { v4 } from 'uuid';
import { AnalyticsStore } from '../../stores';
import { StatisticsByGroups } from './statistics-by-groups/statistics-by-groups';

@Component({
  selector: 'app-analytic-statistics-card',
  imports: [
    CommonModule,
    Card,
    CardHeader,
    CardHeaderTitle,
    SelectModule,
    FormsModule,
    DonutSummaryChart,
    SelectButtonModule,
    SkeletonModule,
    StatisticsByGroups,
  ],
  providers: [DatePipe],
  template: `
    <app-card>
      <app-card-header class="flex items-center justify-between">
        <app-card-header-title>Statistics</app-card-header-title>
        <p-select
          append-right
          [ngModel]="type()"
          (ngModelChange)="type.set($event)"
          [options]="typesOptions()"
          optionLabel="name"
          size="small"
          [dt]="{
            root: {
              borderRadius: '12px',
            },
          }"
        />
      </app-card-header>

      @if (store.isGroupsStatisticsLoading()) {
        <div class="flex flex-col justify-end gap-4">
          <p-skeleton height="1rem" />
          <p-skeleton height="1rem" />
          <p-skeleton height="1rem" />
          <p-skeleton height="1rem" />
          <div class="flex gap-2 mt-20">
            <p-skeleton width="4rem" />
            <p-skeleton width="4rem" />
            <p-skeleton width="4rem" />
            <p-skeleton width="4rem" />
            <p-skeleton width="4rem" />
            <p-skeleton width="4rem" />
            <p-skeleton width="4rem" />
          </div>
        </div>
      } @else {
        <div class="flex flex-col min-w-80">
          <app-donut-summary-chart
            [title]="chartLabel()"
            [currency]="store.selectedCurrencyCode()"
            [items]="displayedItems()"
            size="large"
            class="py-6 self-center"
          />

          <app-statistics-by-groups [groups]="displayedItems()" />
        </div>
      }
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AnalyticStatisticsCard {
  private readonly datePipe = inject(DatePipe);
  protected readonly store = inject(AnalyticsStore);

  protected readonly typesOptions = signal([
    { name: 'Expenses' },
    { name: 'Income' },
    { name: 'Budget' },
  ]);

  protected readonly type = signal<{ name: string }>({ name: 'Expenses' });

  protected readonly chartLabel = computed(() => {
    const monthString = this.datePipe.transform(
      this.store.selectedMonth(),
      'MM/yy',
    );
    const typeName = this.type().name;
    const label =
      typeName === 'Income'
        ? 'Income for'
        : typeName === 'Expenses'
          ? 'Expenses for'
          : 'Budget for';
    return label + ' ' + monthString;
  });

  private readonly coloredIncomes = computed(() => {
    const items = this.store.incomeByGroups().filter((g) => g.amount > 0);
    const sorted = [...items].sort((a, b) => b.amount - a.amount);
    const colors = generateAnalogColors(sorted.length);
    return sorted.map((g, index) => ({
      id: v4(),
      name: g.groupName,
      amount: g.amount,
      color: colors[index],
    }));
  });

  private readonly coloredExpenses = computed(() => {
    const items = this.store.expenseByGroups().filter((g) => g.amount > 0);
    const sorted = [...items].sort((a, b) => b.amount - a.amount);
    const colors = generateAnalogColors(sorted.length);
    return sorted.map((g, index) => ({
      id: v4(),
      name: g.groupName,
      amount: g.amount,
      color: colors[index],
    }));
  });

  private readonly coloredBudgets = computed(() => {
    const items = this.store.budgetByGroups().filter((g) => g.amount > 0);
    const sorted = [...items].sort((a, b) => b.amount - a.amount);
    const colors = generateAnalogColors(sorted.length);
    return sorted.map((g, index) => ({
      id: v4(),
      name: g.groupName,
      amount: g.amount,
      color: colors[index],
    }));
  });

  protected readonly displayedItems = computed(() => {
    const typeName = this.type().name;
    if (typeName === 'Income') return this.coloredIncomes();
    if (typeName === 'Budget') return this.coloredBudgets();
    return this.coloredExpenses();
  });
}
