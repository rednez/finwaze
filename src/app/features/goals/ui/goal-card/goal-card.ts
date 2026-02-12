import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
} from '@angular/core';
import { Goal } from '@core/models/goal';
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
        Due date – {{ goal().dueDate | date: 'mediumDate' }}
      </div>
    </div>

    <div class="flex items-baseline gap-1">
      <app-styled-amount
        [amount]="goal().savingAmount"
        [currency]="goal().currency"
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
          {{ remainedAmount() | currency: goal().currency }}
        </div>
      </div>
    </div>
  `,
  styles: `
    @reference "tailwindcss";

    :host {
      @apply relative flex flex-col gap-4 border border-gray-200 
      dark:border-gray-600 rounded-3xl p-4;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GoalCard {
  readonly goal = input.required<Goal>();

  protected readonly percents = computed(() =>
    Math.floor((this.goal().savingAmount / this.goal().targetAmount) * 100),
  );

  protected readonly remainedAmount = computed(
    () => this.goal().targetAmount - this.goal().savingAmount,
  );
}
