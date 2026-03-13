import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';

@Component({
  selector: 'app-financial-trend-badge',
  imports: [CommonModule],
  template: `
    <div
      class="flex items-center gap-1 rounded-full px-3 py-1 w-fit"
      [class]="color()"
    >
      @if (absDelta() !== 0) {
        <span class="material-symbols-rounded text-sm!">
          {{ icon() }}
        </span>
      }
      <div class="text-sm">
        {{ absDelta() | percent: '1.0-1' }}
      </div>
    </div>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FinancialTrendBadge {
  readonly currentAmount = input(0);
  readonly previousAmount = input(0);
  readonly growTrendIsGood = input(false);

  private readonly delta = computed(() => {
    const previous = this.previousAmount();
    if (previous === 0) {
      return 0;
    }
    return (this.currentAmount() - previous) / previous;
  });

  protected readonly absDelta = computed(() => Math.abs(this.delta()));

  protected readonly icon = computed(() =>
    this.delta() > 0 ? 'north' : 'south',
  );

  protected readonly color = computed(() => {
    if (this.isPositiveTrend()) {
      return 'text-green-600 bg-green-100 dark:text-green-500 dark:bg-green-950';
    }

    if (this.isNegativeTrend()) {
      return 'text-red-600 bg-red-100 dark:text-red-500 dark:bg-red-950';
    }

    return 'text-gray-600 bg-gray-100';
  });

  private readonly isPositiveTrend = computed(() =>
    this.growTrendIsGood() ? this.delta() > 0 : this.delta() < 0,
  );

  private readonly isNegativeTrend = computed(() =>
    this.growTrendIsGood() ? this.delta() < 0 : this.delta() > 0,
  );

  private readonly isNeutralTrend = computed(() => this.delta() === 0);
}
