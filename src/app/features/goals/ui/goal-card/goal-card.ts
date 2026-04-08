import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  output,
} from '@angular/core';
import { Router } from '@angular/router';
import { SavingsGoal } from '@core/models/savings-goal';
import { ProgressBar } from '@shared/ui/progress-bar';
import { StyledAmount } from '@shared/ui/styled-amount';
import { ButtonModule } from 'primeng/button';
import { GoalCardStatus } from '../goal-card-status/goal-card-status';

@Component({
  selector: 'app-goal-card',
  imports: [
    CommonModule,
    StyledAmount,
    ProgressBar,
    GoalCardStatus,
    ButtonModule,
  ],
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
        <div class="text-muted-color">{{ statusLabel() }}</div>
        @if (goal().status === 'inProgress') {
          <div class="font-medium">
            {{ remainedAmount() | currency: goal().currencyCode }}
          </div>
        }
      </div>
    </div>

    @if (canDeposit()) {
      <div class="flex gap-2">
        <p-button
          icon="pi pi-arrow-circle-down"
          label="Deposit"
          size="small"
          severity="success"
          [rounded]="true"
          (onClick)="deposit($event)"
        />
        @if (canWithdraw()) {
          <p-button
            icon="pi pi-arrow-circle-up"
            label="Withdraw"
            size="small"
            severity="secondary"
            [rounded]="true"
            (onClick)="withdraw($event)"
          />
        }
      </div>
    }
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
  readonly depositClicked = output<SavingsGoal>();
  readonly withdrawClicked = output<SavingsGoal>();

  private readonly router = inject(Router);

  navigate() {
    this.router.navigate(['/goals', this.goal().id]);
  }

  protected readonly canDeposit = computed(
    () =>
      this.goal().status === 'notStarted' ||
      this.goal().status === 'inProgress',
  );

  protected readonly canWithdraw = computed(
    () =>
      this.goal().accumulatedAmount > 0 &&
      (this.goal().status === 'notStarted' ||
        this.goal().status === 'inProgress'),
  );

  protected readonly percents = computed(() =>
    Math.floor(
      (this.goal().accumulatedAmount / this.goal().targetAmount) * 100,
    ),
  );

  protected readonly remainedAmount = computed(
    () => this.goal().targetAmount - this.goal().accumulatedAmount,
  );

  protected readonly statusLabel = computed(() => {
    const labels: Record<string, string> = {
      notStarted: 'Goal not started',
      inProgress: 'Left to complete the goal',
      done: 'Goal completed',
      cancelled: 'Goal cancelled',
    };
    return labels[this.goal().status];
  });

  protected deposit(event: Event): void {
    event.stopPropagation();
    this.depositClicked.emit(this.goal());
  }

  protected withdraw(event: Event): void {
    event.stopPropagation();
    this.withdrawClicked.emit(this.goal());
  }
}
