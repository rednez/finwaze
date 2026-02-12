import { CommonModule, DatePipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { DonutSummaryChart } from '@shared/ui/donut-summary-chart';
import { generateAnalogColors } from '@core/utils/colors';
import { SelectModule } from 'primeng/select';
import { SelectButtonModule } from 'primeng/selectbutton';
import { v4 } from 'uuid';
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
    StatisticsByGroups,
  ],
  providers: [DatePipe],
  template: `
    <app-card>
      <app-card-header class="flex items-center justify-between">
        <app-card-header-title>Statistics</app-card-header-title>
        <p-select
          [(ngModel)]="type"
          [options]="typesOptions()"
          optionLabel="name"
          size="small"
          [dt]="{
            root: {
              borderRadius: '16px',
            },
          }"
        />
      </app-card-header>

      <div class="flex flex-col">
        <app-donut-summary-chart
          [title]="chartLabel()"
          [currency]="currency()"
          [items]="displayedItems()"
          size="large"
          class="py-6 self-center"
        />

        <app-statistics-by-groups [groups]="displayedItems()" />
      </div>
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AnalyticStatisticsCard {
  private readonly datePipe = inject(DatePipe);

  protected readonly typesOptions = signal([
    { name: 'Expenses' },
    { name: 'Income' },
    { name: 'Budget' },
  ]);

  protected type: { name: string } = { name: 'Expenses' };

  readonly incomes = signal([
    {
      name: 'Salary',
      amount: 500,
    },
    {
      name: 'Взятки',
      amount: 900,
    },
    {
      name: 'Допомога',
      amount: 100,
    },
    {
      name: 'Подарунки',
      amount: 2400,
    },
    {
      name: 'Продаж',
      amount: 1200,
    },
    {
      name: 'Кредити',
      amount: 1000,
    },
    {
      name: 'Інвестиції',
      amount: 500,
    },
  ]);

  readonly expenses = signal([
    {
      name: 'Taxes',
      amount: 500,
    },
    {
      name: 'Life',
      amount: 900,
    },
    {
      name: 'Medicine',
      amount: 100,
    },
    {
      name: 'Foods',
      amount: 2400,
    },
    {
      name: 'Credits',
      amount: 1200,
    },
    {
      name: 'Car',
      amount: 1000,
    },
    {
      name: 'Stuff',
      amount: 500,
    },
  ]);

  readonly budgets = signal([]);

  readonly currency = signal('UAH');
  readonly month = signal(new Date());

  protected readonly displayedItems = computed(() =>
    this.type.name === 'Expenses'
      ? this.displayedIncomes()
      : this.displayedExpenses(),
  );

  protected readonly chartLabel = computed(() => {
    const monthString = this.datePipe.transform(this.month(), 'MM/yy');
    const label =
      this.type.name === 'Income'
        ? 'Income for'
        : this.type.name === 'Expenses'
          ? 'Expenses for'
          : 'Budget for';
    return label + ' ' + monthString;
  });

  private readonly displayedIncomes = computed(() => {
    const colors = generateAnalogColors(this.incomes().length);
    return this.incomes()
      .sort((a, b) => b.amount - a.amount)
      .map((cat, index) => ({
        ...cat,
        id: v4(),
        color: colors[index],
      }));
  });

  private readonly displayedExpenses = computed(() => {
    const colors = generateAnalogColors(this.expenses().length);
    return this.expenses()
      .sort((a, b) => b.amount - a.amount)
      .map((cat, index) => ({
        ...cat,
        id: v4(),
        color: colors[index],
      }));
  });
}
