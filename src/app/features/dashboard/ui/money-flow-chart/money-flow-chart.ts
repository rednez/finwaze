import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
} from '@angular/core';
import { LocalizationService } from '@core/services/localization.service';
import { ThemeService } from '@core/services/theme.service';
import { ChartModule } from 'primeng/chart';

@Component({
  selector: 'app-money-flow-chart',
  imports: [ChartModule],
  template: `
    <p-chart type="bar" [data]="data()" [options]="options()" class="h-50" />
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class MoneyFlowChart {
  private readonly isDarkModeSignal = inject(ThemeService).isDark;
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  readonly labels = input.required<string[]>();
  readonly incomes = input.required<number[]>();
  readonly expenses = input.required<number[]>();

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
    const expense = documentStyle.getPropertyValue('--p-primary-300');
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
        label: this.t('dashboard.chart.income'),
        backgroundColor: this.chartColors().income,
        borderColor: this.chartColors().income,
        data: this.incomes(),
      },
      {
        label: this.t('dashboard.chart.expense'),
        backgroundColor: this.chartColors().expense,
        borderColor: this.chartColors().expense,
        data: this.expenses(),
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
        labels: { color: this.chartColors().textColor, usePointStyle: true },
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
          font: { weight: 400 },
        },
        grid: { color: this.chartColors().surfaceBorder, drawBorder: false },
      },
      y: {
        ticks: { color: this.chartColors().textColorSecondary },
        grid: { color: this.chartColors().surfaceBorder, drawBorder: false },
      },
    },
  }));
}
