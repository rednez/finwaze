import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';

@Component({
  selector: 'app-budget-expense-item',
  imports: [CommonModule],
  template: `
    <div>
      <div class="font-medium">
        {{ currentAmount() | currency: currency() }}
      </div>
      <div class="text-sm text-muted-color">{{ name() }}</div>
    </div>

    <div
      class="flex items-center gap-1 rounded-full px-3 py-1 h-fit"
      [class]="color()"
    >
      <span class="material-symbols-rounded text-sm!">
        {{ icon() }}
      </span>
      <div class="text-sm">{{ absDelta() | percent: '1.0-1' }}</div>
    </div>
  `,
  host: {
    class: 'flex items-center justify-between',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetExpenseItem {
  readonly name = input.required<string>();
  readonly currentAmount = input(0);
  readonly previousPeriodAmount = input(0);
  readonly currency = input.required<string>();

  private readonly delta = computed(
    () =>
      (this.currentAmount() - this.previousPeriodAmount()) /
      this.previousPeriodAmount(),
  );

  protected readonly absDelta = computed(() => Math.abs(this.delta()));

  protected readonly icon = computed(() =>
    this.delta() > 0 ? 'north' : 'south',
  );

  protected readonly color = computed(() => ({
    'text-red-600': this.delta() > 0,
    'text-green-600': this.delta() <= 0,
    'dark:text-red-500': this.delta() > 0,
    'dark:text-green-500': this.delta() <= 0,
    'bg-red-100': this.delta() > 0,
    'bg-green-100': this.delta() <= 0,
    'dark:bg-red-950': this.delta() > 0,
    'dark:bg-green-950': this.delta() <= 0,
  }));
}
