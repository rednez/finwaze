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

  private readonly delta = computed(
    () =>
      (this.currentAmount() - this.previousAmount()) / this.previousAmount(),
  );

  protected readonly absDelta = computed(() => Math.abs(this.delta()));

  protected readonly icon = computed(() =>
    this.delta() > 0 ? 'north' : 'south',
  );

  protected readonly color = computed(() => ({
    'text-green-600': this.isPositiveTrend(),
    'text-red-600': this.isNegativeTrend(),
    'text-gray-600': this.isNeutralTrend(),
    'bg-green-100': this.isPositiveTrend(),
    'bg-red-100': this.isNegativeTrend(),
    'bg-gray-100': this.isNeutralTrend(),
    'dark:text-green-500': this.isPositiveTrend(),
    'dark:text-red-500': this.isNegativeTrend(),
    'dark:bg-green-950': this.isPositiveTrend(),
    'dark:bg-red-950': this.isNegativeTrend(),
  }));

  private readonly isPositiveTrend = computed(() =>
    this.growTrendIsGood() ? this.delta() > 0 : this.delta() < 0,
  );

  private readonly isNegativeTrend = computed(() =>
    this.growTrendIsGood() ? this.delta() < 0 : this.delta() > 0,
  );

  private readonly isNeutralTrend = computed(() => this.delta() === 0);
}
