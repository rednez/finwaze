import { CommonModule, DatePipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
} from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { DarkModeHelper } from '@services/dark-mode-helper';
import { ChartModule } from 'primeng/chart';

@Component({
  selector: 'app-transactions-overview-chart',
  imports: [ChartModule],
  template: `
    <p-chart type="line" [data]="data()" [options]="options()" class="h-50" />
  `,
  styles: ``,
  providers: [DatePipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TransactionsOverviewChart {
  private readonly darkModeHelper = inject(DarkModeHelper);
  private readonly datePipe = inject(DatePipe);

  readonly labels = input.required<string[]>();
  readonly incomes = input.required<number[]>();
  readonly expenses = input.required<number[]>();

  private readonly isDarkModeSignal = toSignal(
    this.darkModeHelper.isDarkModeChanges$,
  );

  protected readonly colors = computed(() => {
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
    labels: this.labels().map((i) => this.datePipe.transform(i, 'd MMM')),
    datasets: [
      {
        label: 'Income',
        backgroundColor: this.colors().income,
        borderColor: this.colors().income,
        data: this.incomes(),
        borderWidth: 2,
        tension: 0.4,
        pointRadius: 0,
      },
      {
        label: 'Expense',
        backgroundColor: this.colors().expense,
        borderColor: this.colors().expense,
        data: this.expenses(),
        borderWidth: 2,
        tension: 0.4,
        pointRadius: 0,
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
          color: this.colors().textColor,
          usePointStyle: true,
        },
      },
      tooltip: {
        backgroundColor: this.colors().tooltipBg,
        borderColor: this.colors().surfaceBorder,
        borderWidth: 1,
        bodyColor: this.colors().textColor,
        titleColor: this.colors().textColor,
      },
    },
    scales: {
      x: {
        ticks: {
          color: this.colors().textColorSecondary,
          font: {
            weight: 400,
          },
        },
        grid: {
          color: this.colors().surfaceBorder,
          drawBorder: false,
        },
      },
      y: {
        ticks: {
          color: this.colors().textColorSecondary,
        },
        grid: {
          color: this.colors().surfaceBorder,
          drawBorder: false,
        },
      },
    },
  }));
}
