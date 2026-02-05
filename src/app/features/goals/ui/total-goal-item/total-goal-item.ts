import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';
import { GoalStatus } from '@models/goal';

@Component({
  selector: 'app-total-goal-item',
  imports: [],
  template: `
    <div
      class="size-12 flex shrink-0 items-center justify-center rounded-full"
      [class.bg-emerald-100]="status() === 'inProgress'"
      [class.bg-amber-100]="status() === 'notStarted'"
      [class.bg-primary-100]="status() === 'done'"
      [class.bg-rose-100]="status() === 'cancelled'"
      [class.dark:bg-emerald-900]="status() === 'inProgress'"
      [class.dark:bg-amber-900]="status() === 'notStarted'"
      [class.dark:bg-primary-900]="status() === 'done'"
      [class.dark:bg-rose-900]="status() === 'cancelled'"
    >
      <div
        class="material-icons-outlined"
        [class.text-emerald-500]="status() === 'inProgress'"
        [class.text-amber-500]="status() === 'notStarted'"
        [class.text-primary-500]="status() === 'done'"
        [class.text-rose-500]="status() === 'cancelled'"
      >
        {{ statusIcon() }}
      </div>
    </div>

    <div class="text-center w-full">
      <div
        class="text-sm font-medium"
        [class.text-emerald-500]="status() === 'inProgress'"
        [class.text-amber-500]="status() === 'notStarted'"
        [class.text-primary-500]="status() === 'done'"
        [class.text-rose-500]="status() === 'cancelled'"
        [class.dark:text-emerald-600]="status() === 'inProgress'"
        [class.dark:text-amber-600]="status() === 'notStarted'"
        [class.dark:text-primary-600]="status() === 'done'"
        [class.tdark:ext-rose-600]="status() === 'cancelled'"
      >
        {{ statusLabel() }}
      </div>
      <div class="font-medium">3</div>
    </div>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    class:
      'flex gap-2 items-center border border-surface-200 dark:border-surface-600 rounded-full pl-1 pr-4 py-1 min-w-39 grow',
  },
})
export class TotalGoalItem {
  readonly status = input<GoalStatus>('notStarted');
  readonly count = input(0);

  protected readonly statusLabel = computed(() => {
    switch (this.status()) {
      case 'inProgress':
        return 'In progress';
      case 'done':
        return 'Done';
      case 'cancelled':
        return 'Cancelled';
      case 'notStarted':
      default:
        return 'Not started';
    }
  });

  protected readonly statusIcon = computed(() => {
    switch (this.status()) {
      case 'inProgress':
        return 'alarm';
      case 'done':
        return 'done';
      case 'cancelled':
        return 'alarm_off';
      case 'notStarted':
      default:
        return 'pause_circle';
    }
  });
}
