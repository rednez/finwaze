import { Component, computed, inject, input } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { DarkModeHelper } from '@services';
import { ChartModule } from 'primeng/chart';

@Component({
  selector: 'app-money-flow-chart',
  imports: [ChartModule],
  template: `<p-chart type="bar" [data]="data()" [options]="options()" />`,
})
export class MoneyFlowChart {
  private readonly darkModeHelper = inject(DarkModeHelper);

  readonly labels = input.required<string[]>();
  readonly incomes = input.required<number[]>();
  readonly expenses = input.required<number[]>();

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
    const income = this.isDarkModeSignal()
      ? documentStyle.getPropertyValue('--p-primary-500')
      : documentStyle.getPropertyValue('--p-primary-color');
    const expense = this.isDarkModeSignal()
      ? documentStyle.getPropertyValue('--p-primary-300')
      : documentStyle.getPropertyValue('--p-primary-300');
    const tooltipBg = this.isDarkModeSignal()
      ? documentStyle.getPropertyValue('--p-gray-800')
      : 'white';

    return {
      textColor,
      textColorSecondary,
      surfaceBorder,
      income,
      expense,
      tooltipBg,
    };
  });

  protected readonly data = computed(() => ({
    labels: this.labels(),
    datasets: [
      {
        label: 'Income',
        backgroundColor: this.chartColors().income,
        borderColor: this.chartColors().income,
        data: this.incomes(),
      },
      {
        label: 'Expense',
        backgroundColor: this.chartColors().expense,
        borderColor: this.chartColors().expense,
        data: this.expenses(),
      },
    ],
  }));

  protected readonly options = computed(() => ({
    maintainAspectRatio: false,
    aspectRatio: 0.9,
    plugins: {
      legend: {
        labels: {
          color: this.chartColors().textColor,
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
