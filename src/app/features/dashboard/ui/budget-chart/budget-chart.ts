import { Component, computed, inject, input } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { DarkModeHelper } from '@services';
import { StyledAmount } from '@ui';
import { ChartModule } from 'primeng/chart';

@Component({
  selector: 'app-budget-chart',
  imports: [ChartModule, StyledAmount],
  template: `
    <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
      <div class="text-sm text-muted-color">Total for month</div>
      <app-styled-amount
        [currency]="currency()"
        [amount]="sumAmount()"
        size="sm"
      />
    </div>
    <p-chart
      type="doughnut"
      [data]="data()"
      [options]="options()"
      class="size-50"
    />
  `,
  host: {
    class: 'relative',
  },
})
export class BudgetChart {
  private readonly darkModeHelper = inject(DarkModeHelper);

  readonly categories =
    input.required<
      Array<{ id: number; name: string; chartColor: string; amount: number }>
    >();
  readonly currency = input.required<string>();

  private readonly sortedCategories = computed(() =>
    this.categories().sort((a, b) => b.amount - a.amount),
  );

  private amounts = computed(() =>
    this.sortedCategories().map((cat) => cat.amount),
  );

  private colors = computed(() =>
    this.sortedCategories().map((cat) => {
      const documentStyle = getComputedStyle(document.documentElement);
      return documentStyle.getPropertyValue(cat.chartColor);
    }),
  );

  protected readonly sumAmount = computed(() =>
    this.categories().reduce((sum, cat) => sum + cat.amount, 0),
  );

  private readonly isDarkModeSignal = toSignal(
    this.darkModeHelper.isDarkModeChanges$,
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
    datasets: [
      {
        data: this.amounts(),
        backgroundColor: this.colors(),
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
        labels: {},
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
}
