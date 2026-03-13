import { DatePipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
} from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { DarkModeHelper } from '@core/services/dark-mode-helper';
import { ChartModule } from 'primeng/chart';

@Component({
  selector: 'app-budgets-expenses-chart',
  imports: [ChartModule],
  providers: [DatePipe],
  template: `
    <p-chart type="bar" [data]="data()" [options]="options()" class="h-50" />
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetsExpensesChart {
  private readonly darkModeHelper = inject(DarkModeHelper);
  private readonly datePipe = inject(DatePipe);

  readonly labels = input<string[]>([]);
  readonly expenses = input<number[]>([]);
  readonly budgets = input<number[]>([]);

  private readonly isDarkModeSignal = toSignal(
    this.darkModeHelper.isDarkModeChanges$,
  );

  protected readonly chartColors = computed(() => {
    const documentStyle = getComputedStyle(document.documentElement);

    const textColor = documentStyle.getPropertyValue('--p-text-color');
    const textColorSecondary = documentStyle.getPropertyValue(
      '--p-text-muted-color',
    );
    const surfaceBorder = documentStyle.getPropertyValue(
      '--p-content-border-color',
    );
    const expense = this.isDarkModeSignal()
      ? documentStyle.getPropertyValue('--p-primary-500')
      : documentStyle.getPropertyValue('--p-primary-color');
    const budget = this.isDarkModeSignal()
      ? documentStyle.getPropertyValue('--p-primary-300')
      : documentStyle.getPropertyValue('--p-primary-300');
    const tooltipBg = this.isDarkModeSignal()
      ? documentStyle.getPropertyValue('--p-gray-800')
      : 'white';

    return {
      textColor,
      textColorSecondary,
      surfaceBorder,
      budget,
      expense,
      tooltipBg,
    };
  });

  protected readonly data = computed(() => ({
    labels: this.labels().map((i) => this.datePipe.transform(i, 'MMM')),
    datasets: [
      {
        label: 'Expenses',
        backgroundColor: this.chartColors().expense,
        borderColor: this.chartColors().expense,
        data: this.expenses(),
      },
      {
        label: 'Budgets',
        backgroundColor: this.chartColors().budget,
        borderColor: this.chartColors().budget,
        data: this.budgets(),
      },
    ],
  }));

  protected readonly options = computed(() => ({
    maintainAspectRatio: false,
    aspectRatio: 1.6,
    borderRadius: 100,
    plugins: {
      legend: {
        display: true,
        labels: {
          color: this.chartColors().textColor,
          usePointStyle: true,
        },
      },
      tooltip: {
        backgroundColor: this.chartColors().tooltipBg,
        borderColor: this.chartColors().surfaceBorder,
        borderWidth: 1,
        bodyColor: this.chartColors().textColor,
        titleColor: this.chartColors().textColor,
      },
    },
    scales: {
      x: {
        ticks: {
          color: this.chartColors().textColorSecondary,
          font: {
            weight: 400,
          },
        },
        grid: {
          color: this.chartColors().surfaceBorder,
          drawBorder: false,
        },
      },
      y: {
        ticks: {
          color: this.chartColors().textColorSecondary,
        },
        grid: {
          color: this.chartColors().surfaceBorder,
          drawBorder: false,
        },
      },
    },
  }));
}
