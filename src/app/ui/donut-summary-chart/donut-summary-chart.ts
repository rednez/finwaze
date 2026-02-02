import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
} from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { DarkModeHelper } from '@services/dark-mode-helper';
import { StyledAmount } from '@ui/styled-amount';
import { ChartModule } from 'primeng/chart';

type SummaryItem = {
  name: string;
  amount: number;
  color: string;
};

@Component({
  selector: 'app-donut-summary-chart',
  imports: [ChartModule, StyledAmount],
  template: `
    <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
      <div class="text-sm text-muted-color text-center">{{ title() }}</div>
      <app-styled-amount
        [currency]="currency()"
        [amount]="totalAmount()"
        size="sm"
      />
    </div>
    <p-chart
      type="doughnut"
      [data]="data()"
      [options]="options()"
      [class.size-50]="size() === 'medium'"
      [class.size-62]="size() === 'large'"
    />
  `,
  host: {
    class: 'relative block w-fit',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DonutSummaryChart {
  private readonly darkModeHelper = inject(DarkModeHelper);

  readonly title = input.required<string>();
  readonly items = input.required<SummaryItem[]>();
  readonly currency = input.required<string>();
  readonly size = input<'medium' | 'large'>('medium');

  private amounts = computed(() => this.items().map((cat) => cat.amount));

  protected readonly totalAmount = computed(() =>
    this.items().reduce((sum, cat) => sum + cat.amount, 0),
  );

  protected readonly chartColors = computed(() => {
    const documentStyle = getComputedStyle(document.documentElement);

    const tooltipBg = this.isDarkModeSignal()
      ? documentStyle.getPropertyValue('--p-gray-800')
      : 'white';
    const textColor = documentStyle.getPropertyValue('--p-text-color');
    const surfaceBorder = documentStyle.getPropertyValue(
      '--p-content-border-color',
    );

    return {
      tooltipBg,
      textColor,
      surfaceBorder,
    };
  });

  protected readonly data = computed(() => ({
    labels: this.items().map((item) => item.name),
    datasets: [
      {
        data: this.amounts(),
        backgroundColor: this.items().map((item) => item.color),
      },
    ],
  }));

  protected readonly options = computed(() => ({
    cutout: '80%',
    borderRadius: 4,
    borderWidth: 0,
    spacing: 4,
    plugins: {
      legend: {
        display: false,
      },
      tooltip: {
        backgroundColor: this.chartColors().tooltipBg,
        borderColor: this.chartColors().surfaceBorder,
        borderWidth: 1,
        bodyColor: this.chartColors().textColor,
        titleColor: this.chartColors().textColor,
      },
    },
  }));

  private readonly isDarkModeSignal = toSignal(
    this.darkModeHelper.isDarkModeChanges$,
  );
}
