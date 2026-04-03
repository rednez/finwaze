import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
} from '@angular/core';
import { Router } from '@angular/router';
import { SavingsGoal } from '@core/models/savings-goal';
import { ProgressBar } from '@shared/ui/progress-bar';
import { StyledAmount } from '@shared/ui/styled-amount';
import { GoalCardStatus } from '../goal-card-status/goal-card-status';

@Component({
  selector: 'app-goal-card',
  imports: [CommonModule, StyledAmount, ProgressBar, GoalCardStatus],
  template: `
    <app-goal-card-status [status]="goal().status" />

    <div>
      <div
        class="text-lg font-medium whitespace-nowrap overflow-hidden text-ellipsis"
      >
        {{ goal().name }}
      </div>
      <div class="text-muted-color">
        Due date – {{ goal().targetDate | date: 'mediumDate' }}
      </div>
    </div>

    <div class="flex items-baseline gap-1">
      <app-styled-amount
        [amount]="goal().accumulatedAmount"
        [currency]="goal().currencyCode"
      />
      <div class="text-primary-500 font-medium">
        / {{ goal().targetAmount | number }}
      </div>
    </div>

    <div>
      <app-progress-bar [value]="percents()" />
      <div class="flex justify-between gap-2 text-sm mt-2">
        <div class="text-muted-color">Left to complete the goal</div>
        <div class="font-medium">
          {{ remainedAmount() | currency: goal().currencyCode }}
        </div>
      </div>
    </div>
  `,
  host: {
    class:
      'relative flex flex-col gap-4 border border-gray-200 dark:border-gray-600 rounded-3xl p-4 cursor-pointer hover:border-primary-400 dark:hover:border-primary-500 transition-colors',
    '(click)': 'navigate()',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GoalCard {
  readonly goal = input.required<SavingsGoal>();

  private readonly router = inject(Router);

  navigate() {
    this.router.navigate(['/goals', this.goal().id]);
  }

  protected readonly percents = computed(() =>
    Math.floor(
      (this.goal().accumulatedAmount / this.goal().targetAmount) * 100,
    ),
  );

  protected readonly remainedAmount = computed(
    () => this.goal().targetAmount - this.goal().accumulatedAmount,
  );
}
