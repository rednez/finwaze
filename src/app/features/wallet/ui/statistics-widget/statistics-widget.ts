import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
  linkedSignal,
  model,
  output,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { generateAnalogColors } from '@core/utils/colors';
import { toNameOptions } from '@core/utils/input-transforms';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { DonutSummaryChart } from '@shared/ui/donut-summary-chart';
import { DatePickerModule } from 'primeng/datepicker';
import { IftaLabelModule } from 'primeng/iftalabel';
import { SelectModule } from 'primeng/select';
import { SelectButtonModule } from 'primeng/selectbutton';
import { v4 } from 'uuid';
import { MonthlySummary } from '../../models';
import { StatisticsByGroups } from './statistics-by-groups/statistics-by-groups';

@Component({
  selector: 'app-wallet-statistics-widget',
  imports: [
    Card,
    SelectModule,
    IftaLabelModule,
    DatePickerModule,
    FormsModule,
    DonutSummaryChart,
    SelectButtonModule,
    StatisticsByGroups,
    CardHeader,
    CardHeaderTitle,
  ],
  template: `
    <app-card>
      <app-card-header class="flex items-center justify-between">
        <app-card-header-title>Statistics</app-card-header-title>
        <div append-right class="flex gap-2">
          <p-datepicker
            [ngModel]="month()"
            (ngModelChange)="monthChanged.emit($event)"
            dateFormat="mm/yy"
            [readonlyInput]="true"
            size="small"
            view="month"
            class="w-21"
            [inputStyle]="{
              borderRadius: '12px',
            }"
          />

          <p-select
            [ngModel]="currency()"
            (ngModelChange)="onCurrencyChange($event)"
            [options]="currencies()"
            optionLabel="name"
            optionValue="name"
            size="small"
            [dt]="{
              root: {
                borderRadius: '12px',
              },
            }"
          />
        </div>
      </app-card-header>

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

        <app-wallet-statistics-by-groups [groups]="displayedItems()" />
      </div>
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class StatisticsWidget {
  readonly data = input<MonthlySummary[]>([]);
  readonly currencies = input<{ name: string }[], string[]>([], {
    transform: toNameOptions,
  });
  readonly initialCurrency = input<string>();
  readonly initialMonth = input(new Date());
  readonly monthChanged = output<Date>();
  readonly currencyChanged = output<string>();

  protected readonly month = linkedSignal(() => this.initialMonth());
  protected readonly currency = linkedSignal(() => this.initialCurrency());
  protected readonly typeOptions = [
    { value: 'expense', label: 'Expense' },
    { value: 'income', label: 'Income' },
  ];
  protected readonly selectedType = model('expense');

  readonly incomes = computed(() =>
    this.data()
      .filter((i) => i.totalIncome > 0)
      .map((i) => ({
        name: i.groupName,
        amount: i.totalIncome,
      })),
  );

  readonly expenses = computed(() =>
    this.data()
      .filter((i) => i.totalExpense > 0)
      .map((i) => ({
        name: i.groupName,
        amount: i.totalExpense,
      })),
  );

  protected readonly displayedItems = computed(() =>
    this.selectedType() === 'income'
      ? this.displayedIncomes()
      : this.displayedExpenses(),
  );

  protected readonly chartLabel = computed(() =>
    this.selectedType() === 'income' ? 'Total income' : 'Total expenses',
  );

  protected onCurrencyChange(event: string) {
    this.currencyChanged.emit(event);
    this.currency.set(event);
  }

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
