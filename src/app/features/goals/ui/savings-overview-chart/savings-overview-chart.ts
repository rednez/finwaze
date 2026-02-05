import { DatePipe } from '@angular/common';
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
  selector: 'app-savings-overview-chart',
  imports: [ChartModule],
  template: `
    <p-chart type="line" [data]="data()" [options]="options()" class="h-50" />
  `,
  styles: ``,
  providers: [DatePipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SavingsOverviewChart {
  private readonly darkModeHelper = inject(DarkModeHelper);
  private readonly datePipe = inject(DatePipe);

  readonly labels = input<string[]>([]);
  readonly currentSavings = input<number[]>([]);
  readonly previousSavings = input<number[]>([]);

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
    const gradientStop = this.isDarkModeSignal()
      ? 'transparent'
      : 'rgba(255, 255, 255, 0.4)';

    return {
      textColor,
      textColorSecondary,
      surfaceBorder,
      income,
      expense,
      tooltipBg,
      gradientStop,
    };
  });

  protected readonly data = computed(() => ({
    labels: this.labels().map((i) => this.datePipe.transform(i, 'd MMM')),
    datasets: [
      {
        label: 'Selected',
        backgroundColor: ({
          chart,
        }: {
          chart: {
            ctx: CanvasRenderingContext2D;
            chartArea?: { top: number; bottom: number };
          };
        }) => {
          if (!chart.chartArea) {
            return this.colors().income;
          }

          const { ctx, chartArea } = chart;
          const gradient = ctx.createLinearGradient(
            0,
            chartArea.top,
            0,
            chartArea.bottom,
          );
          gradient.addColorStop(0, this.colors().income);
          gradient.addColorStop(1, this.colors().gradientStop);

          return gradient;
        },
        borderColor: this.colors().income,
        data: this.currentSavings(),
        borderWidth: 2,
        fill: true,
        tension: 0.4,
        pointRadius: 0,
      },
      {
        label: 'Previous',
        backgroundColor: this.colors().expense,
        borderColor: this.colors().expense,
        data: this.previousSavings(),
        borderWidth: 2,
        borderDash: [8, 5],
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
