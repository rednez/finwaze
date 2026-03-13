import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';

@Component({
  selector: 'app-budget-status-badge',
  imports: [],
  template: `
    <span class="material-symbols-rounded" [class]="textColor()">
      {{ icon() }}
    </span>

    <span class="text-sm" [class]="textColor()">{{ label() }}</span>
  `,
  host: {
    class: 'flex items-center gap-2 w-fit py-1 pl-1 pr-3 rounded-full',
    '[class.bg-green-100]': 'status() === "onTrack"',
    '[class.bg-yellow-100]': 'status() === "attention"',
    '[class.bg-red-100]': 'status() === "overBudget"',
    '[class.dark:bg-green-950]': 'status() === "onTrack"',
    '[class.dark:bg-yellow-950]': 'status() === "attention"',
    '[class.dark:bg-red-950]': 'status() === "overBudget"',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetStatusBadge {
  readonly budgetAmount = input(0);
  readonly spentAmount = input(0);

  protected readonly status = computed(() =>
    this.leftPercentage() >= 20
      ? 'onTrack'
      : this.leftPercentage() < 20 && this.leftPercentage() >= 0
        ? 'attention'
        : 'overBudget',
  );

  protected readonly icon = computed(() =>
    this.status() === 'onTrack'
      ? 'task_alt'
      : this.status() === 'attention'
        ? 'warning'
        : 'error',
  );

  protected readonly textColor = computed(() => ({
    'text-green-600': this.status() === 'onTrack',
    'text-yellow-600': this.status() === 'attention',
    'text-red-500': this.status() === 'overBudget',
    'dark:text-green-600': this.status() === 'onTrack',
    'dark:text-yellow-600': this.status() === 'attention',
    'dark:text-red-500': this.status() === 'overBudget',
  }));

  protected readonly label = computed(() =>
    this.status() === 'onTrack'
      ? 'on track'
      : this.status() === 'attention'
        ? 'attention'
        : 'over budget',
  );

  private readonly leftPercentage = computed(
    () => 100 - (this.spentAmount() / this.budgetAmount()) * 100,
  );
}
