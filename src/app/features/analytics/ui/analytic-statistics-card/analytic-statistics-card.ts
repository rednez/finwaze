import { CommonModule, DatePipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { LocalizationService } from '@core/services/localization.service';
import { generateAnalogColors } from '@core/utils/colors';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
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

type TypeKey = 'expenses' | 'income' | 'budget';

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
    TranslatePipe,
  ],
  providers: [DatePipe],
  template: `
    <app-card>
      <app-card-header class="flex items-center justify-between">
        <app-card-header-title>{{
          'analytics.statistics.title' | translate
        }}</app-card-header-title>
        <p-select
          append-right
          [ngModel]="typeKey()"
          (ngModelChange)="typeKey.set($event)"
          [options]="typesOptions()"
          optionLabel="name"
          optionValue="value"
          size="small"
          [dt]="{ root: { borderRadius: '12px' } }"
        />
      </app-card-header>

      @if (store.isGroupsStatisticsLoading()) {
        <div class="flex flex-col justify-end gap-4">
          @for (i of [1, 2, 3, 4]; track i) {
            <p-skeleton height="1rem" />
          }
          <div class="flex gap-2 mt-20">
            @for (i of [1, 2, 3, 4, 5, 6, 7]; track i) {
              <p-skeleton width="4rem" />
            }
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
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  protected readonly store = inject(AnalyticsStore);
  protected readonly typeKey = signal<TypeKey>('expenses');

  protected readonly typesOptions = computed(() => [
    {
      value: 'expenses' as TypeKey,
      name: this.t('analytics.statistics.expenses'),
    },
    { value: 'income' as TypeKey, name: this.t('analytics.statistics.income') },
    { value: 'budget' as TypeKey, name: this.t('analytics.statistics.budget') },
  ]);

  protected readonly chartLabel = computed(() => {
    const monthString = this.datePipe.transform(
      this.store.selectedMonth(),
      'MM/yy',
    );
    const key = this.typeKey();
    const prefix =
      key === 'income'
        ? this.t('analytics.statistics.incomeFor')
        : key === 'expenses'
          ? this.t('analytics.statistics.expensesFor')
          : this.t('analytics.statistics.budgetFor');
    return `${prefix} ${monthString}`;
  });

  private readonly coloredIncomes = computed(() => {
    const items = this.store.incomeByGroups().filter((g) => g.amount > 0);
    const sorted = [...items].sort((a, b) => b.amount - a.amount);
    const colors = generateAnalogColors(sorted.length);
    return sorted.map((g, i) => ({
      id: v4(),
      name: g.groupName,
      amount: g.amount,
      color: colors[i],
    }));
  });

  private readonly coloredExpenses = computed(() => {
    const items = this.store.expenseByGroups().filter((g) => g.amount > 0);
    const sorted = [...items].sort((a, b) => b.amount - a.amount);
    const colors = generateAnalogColors(sorted.length);
    return sorted.map((g, i) => ({
      id: v4(),
      name: g.groupName,
      amount: g.amount,
      color: colors[i],
    }));
  });

  private readonly coloredBudgets = computed(() => {
    const items = this.store.budgetByGroups().filter((g) => g.amount > 0);
    const sorted = [...items].sort((a, b) => b.amount - a.amount);
    const colors = generateAnalogColors(sorted.length);
    return sorted.map((g, i) => ({
      id: v4(),
      name: g.groupName,
      amount: g.amount,
      color: colors[i],
    }));
  });

  protected readonly displayedItems = computed(() => {
    const key = this.typeKey();
    if (key === 'income') return this.coloredIncomes();
    if (key === 'budget') return this.coloredBudgets();
    return this.coloredExpenses();
  });
}
