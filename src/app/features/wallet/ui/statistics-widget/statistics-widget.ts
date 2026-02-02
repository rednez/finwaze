import {
  ChangeDetectionStrategy,
  Component,
  computed,
  model,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Card } from '@ui/card';
import { DonutSummaryChart } from '@ui/donut-summary-chart';
import { DatePickerModule } from 'primeng/datepicker';
import { IftaLabelModule } from 'primeng/iftalabel';
import { SelectModule } from 'primeng/select';
import { SelectButtonModule } from 'primeng/selectbutton';
import { generateAnalogColors } from 'src/app/utils/colors';
import { v4 } from 'uuid';
import { StatisticsByGroups } from '../statistics-by-groups/statistics-by-groups';

@Component({
  selector: 'app-statistics-widget',
  imports: [
    Card,
    SelectModule,
    IftaLabelModule,
    DatePickerModule,
    FormsModule,
    DonutSummaryChart,
    SelectButtonModule,
    StatisticsByGroups,
  ],
  template: `
    <app-card>
      <div class="flex items-center justify-between mb-3">
        <div class="text-lg font-medium mb-4">Statistics</div>

        <p-datepicker
          [(ngModel)]="date"
          view="month"
          dateFormat="mm/yy"
          [readonlyInput]="true"
          class="w-22"
          [inputStyle]="{
            borderRadius: '16px',
            fontSize: '14px',
            height: '42px',
          }"
        />
      </div>

      <p-selectbutton
        [options]="typeOptions"
        [(ngModel)]="selectedType"
        optionLabel="label"
        optionValue="value"
        aria-labelledby="basic"
        size="small"
        fluid
      />

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
export class StatisticsWidget {
  protected readonly date = model(new Date());
  protected readonly typeOptions = [
    { value: 'expense', label: 'Expense' },
    { value: 'income', label: 'Income' },
  ];
  protected readonly selectedType = model('expense');

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

  readonly currency = signal('UAH');

  protected readonly displayedItems = computed(() =>
    this.selectedType() === 'income'
      ? this.displayedIncomes()
      : this.displayedExpenses(),
  );

  protected readonly chartLabel = computed(() =>
    this.selectedType() === 'income' ? 'Total income' : 'Total expenses',
  );

  private readonly displayedIncomes = computed(() => {
    const colors = generateAnalogColors(this.incomes().length);

    const sortedIncomes = this.incomes()
      .sort((a, b) => b.amount - a.amount)
      .map((cat, index) => ({
        ...cat,
        id: v4(),
        color: colors[index],
      }));

    return this.incomes().length <= 7
      ? sortedIncomes
      : [
          ...sortedIncomes.slice(0, 6),
          {
            id: v4(),
            name: 'Rest categories',
            amount: sortedIncomes
              .slice(6)
              .reduce((sum, cat) => sum + cat.amount, 0),
            color: '#e2e1e3',
          },
        ];
  });

  private readonly displayedExpenses = computed(() => {
    const colors = generateAnalogColors(this.expenses().length);

    const sortedExpenses = this.expenses()
      .sort((a, b) => b.amount - a.amount)
      .map((cat, index) => ({
        ...cat,
        id: v4(),
        color: colors[index],
      }));

    return this.expenses().length <= 7
      ? sortedExpenses
      : [
          ...sortedExpenses.slice(0, 6),
          {
            id: v4(),
            name: 'Rest categories',
            amount: sortedExpenses
              .slice(6)
              .reduce((sum, cat) => sum + cat.amount, 0),
            color: '#e2e1e3',
          },
        ];
  });
}
