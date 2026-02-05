import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';
import { GoalStatus } from '@models/goal';

@Component({
  selector: 'app-goal-card-status',
  imports: [],
  template: ``,
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    class: 'absolute top-0 left-1/2 -translate-x-1/2 w-1/4 h-1 rounded-b-lg',
    '[class.bg-emerald-600]': 'isInProgress()',
    '[class.bg-amber-600]': 'isNotStarted()',
    '[class.bg-primary-600]': 'isDone()',
    '[class.bg-rose-600]': 'isCancelled()',
  },
})
export class GoalCardStatus {
  readonly status = input<GoalStatus>('inProgress');

  protected readonly isInProgress = computed(
    () => this.status() === 'inProgress',
  );
  protected readonly isNotStarted = computed(
    () => this.status() === 'notStarted',
  );
  protected readonly isDone = computed(() => this.status() === 'done');
  protected readonly isCancelled = computed(
    () => this.status() === 'cancelled',
  );
}
