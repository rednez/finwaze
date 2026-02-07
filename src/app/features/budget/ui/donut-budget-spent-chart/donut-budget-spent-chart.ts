import { CommonModule } from '@angular/common';
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

@Component({
  selector: 'app-donut-budget-spent-chart',
  imports: [CommonModule, ChartModule, StyledAmount],
  template: `
    <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
      <div class="font-medium text-sm text-gray-400 text-center">
        {{ spentPercentage() | percent }} spent
      </div>
      <!-- amount size depends on the screen size -->
      <app-styled-amount
        [currency]="currency()"
        [amount]="spentAmount()"
        class="sm:hidden"
        size="xs"
      />
      <app-styled-amount
        [currency]="currency()"
        [amount]="spentAmount()"
        class="hidden sm:block"
        size="sm"
      />
    </div>
    <p-chart
      type="doughnut"
      [data]="data()"
      [options]="options()"
      [class.size-40]="radiusSize() === 'sm'"
      [class.size-46]="radiusSize() === 'md'"
    />
  `,
  host: {
    class: 'relative block w-fit',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DonutBudgetSpentChart {
  private readonly darkModeHelper = inject(DarkModeHelper);
  private readonly isDarkModeSignal = toSignal(
    this.darkModeHelper.isDarkModeChanges$,
  );

  readonly budgetAmount = input(0);
  readonly spentAmount = input(0);
  readonly currency = input.required<string>();
  readonly radiusSize = input<'sm' | 'md'>('md');

  protected readonly leftAmount = computed(
    () => this.budgetAmount() - this.spentAmount(),
  );

  protected readonly spentPercentage = computed(() => {
    const value = this.spentAmount() / this.budgetAmount();
    return this.leftAmount() < 0 ? value * -1 : value;
  });

  protected readonly chartColors = computed(() => {
    const documentStyle = getComputedStyle(document.documentElement);

    const spentColor = this.isDarkModeSignal()
      ? documentStyle.getPropertyValue('--p-primary-700')
      : documentStyle.getPropertyValue('--p-primary-500');
    const leftColor = this.isDarkModeSignal()
      ? documentStyle.getPropertyValue('--p-surface-800')
      : documentStyle.getPropertyValue('--p-primary-300');
    const overpaymentColor = this.isDarkModeSignal()
      ? documentStyle.getPropertyValue('--p-orange-900')
      : documentStyle.getPropertyValue('--p-red-300');

    return {
      spentColor,
      leftColor,
      overpaymentColor,
    };
  });

  protected readonly data = computed(() => ({
    labels: this.leftAmount() >= 0 ? ['spent', 'left'] : ['spent'],
    datasets: [
      {
        data:
          this.leftAmount() >= 0
            ? [this.spentAmount(), this.leftAmount()]
            : [100],
        backgroundColor:
          this.leftAmount() >= 0
            ? [this.chartColors().spentColor, this.chartColors().leftColor]
            : [this.chartColors().overpaymentColor],
      },
    ],
  }));

  protected readonly options = computed(() => ({
    cutout: '85%',
    borderRadius: 4,
    borderWidth: 0,
    spacing: 1,
    plugins: {
      legend: {
        display: false,
      },
      tooltip: {
        enabled: false,
      },
    },
  }));
}
