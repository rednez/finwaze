import {
  ChangeDetectionStrategy,
  Component,
  inject,
  signal,
} from '@angular/core';
import { RouterLink } from '@angular/router';
import { SavingsGoal } from '@core/models/savings-goal';
import { ButtonModule } from 'primeng/button';
import { SkeletonModule } from 'primeng/skeleton';
import { ToastModule } from 'primeng/toast';
import { MessageService } from 'primeng/api';
import { GoalsListStore } from '../../stores/goals-list-store';
import { SavingsOverviewStore } from '../../stores/savings-overview-store';
import { TotalGoalsStore } from '../../stores/total-goals-store';
import { GoalCard } from '../../ui/goal-card/goal-card';
import { GoalsFilters } from '../../ui/goals-filters/goals-filters';
import { SavingsOverviewWidget } from '../../ui/savings-overview-widget/savings-overview-widget';
import { TotalGoalsCard } from '../../ui/total-goals-card/total-goals-card';
import { TransferToGoalDialog } from '../../ui/transfer-to-goal-dialog/transfer-to-goal-dialog';

@Component({
  imports: [
    GoalCard,
    TotalGoalsCard,
    SavingsOverviewWidget,
    GoalsFilters,
    ButtonModule,
    SkeletonModule,
    RouterLink,
    ToastModule,
    TransferToGoalDialog,
  ],
  providers: [MessageService],
  template: `
    <p-toast />

    <div class="flex justify-between gap-4">
      <app-goals-filters />

      <p-button
        icon="pi pi-plus"
        label="Add new goal"
        [rounded]="true"
        size="large"
        class="shrink-0"
        [dt]="{ root: { lg: { fontSize: '14px' } } }"
        [routerLink]="['create']"
      />
    </div>

    <div class="flex gap-4 flex-wrap">
      @if (goalsListStore.isLoading()) {
        @for (i of [1, 2, 3]; track i) {
          <p-skeleton class="grow sm:max-w-80 rounded-3xl h-56" />
        }
      } @else if (goalsListStore.goals().length === 0) {
        <div
          class="w-full flex flex-col items-center justify-center gap-4 py-12 px-8 text-center border-2 border-dashed border-surface-200 dark:border-surface-700 rounded-3xl"
        >
          <div class="relative">
            <div
              class="absolute inset-0 rounded-full bg-linear-to-br from-violet-200/60 to-purple-200/40 dark:from-violet-500/20 dark:to-purple-500/15 blur-xl scale-125"
            ></div>
            <div
              class="relative flex items-center justify-center w-16 h-16 rounded-2xl bg-linear-to-br from-violet-100 to-purple-100 dark:from-violet-900/40 dark:to-purple-900/35 border border-violet-100 dark:border-violet-800/40 shadow-lg shadow-violet-200/50 dark:shadow-violet-900/40"
            >
              <span class="material-symbols-rounded text-violet-500 text-3xl">
                savings
              </span>
            </div>
          </div>
          <div>
            <p
              class="font-semibold text-surface-800 dark:text-surface-100 mb-1"
            >
              No goals yet
            </p>
            <p class="text-sm text-muted-color">
              Add your first savings goal to start tracking progress.
            </p>
          </div>
          <p-button
            icon="pi pi-plus"
            label="Add new goal"
            [rounded]="true"
            size="large"
            class="shrink-0"
            [dt]="{ root: { lg: { fontSize: '14px' } } }"
            [routerLink]="['create']"
          />
        </div>
      } @else {
        @for (goal of goalsListStore.goals(); track goal.id) {
          <app-goal-card
            [goal]="goal"
            class="grow sm:max-w-80"
            (depositClicked)="openTransferDialog($event)"
          />
        }
      }
    </div>

    <div class="flex gap-4 flex-wrap">
      <app-total-goals-card />

      <app-savings-overview-widget class="grow lg:flex-1 min-w-0" />
    </div>

    @if (selectedGoal()) {
      <app-transfer-to-goal-dialog
        [goal]="selectedGoal()!"
        [(visible)]="dialogVisible"
        [loading]="goalsListStore.isUpdating()"
        (submitted)="handleTransfer($event)"
      />
    }
  `,
  host: {
    class: 'flex flex-col gap-4',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Goals {
  protected readonly goalsListStore = inject(GoalsListStore);
  private readonly totalGoalsStore = inject(TotalGoalsStore);
  private readonly savingsOverviewStore = inject(SavingsOverviewStore);
  private readonly messageService = inject(MessageService);

  protected readonly selectedGoal = signal<SavingsGoal | null>(null);

  constructor() {
    if (this.goalsListStore.isLoaded()) {
      this.goalsListStore.loadGoals();
    }
    if (this.totalGoalsStore.isLoaded()) {
      this.totalGoalsStore.loadGoals();
    }
  }
  protected readonly dialogVisible = signal(false);

  protected openTransferDialog(goal: SavingsGoal): void {
    this.selectedGoal.set(goal);
    this.dialogVisible.set(true);
  }

  protected async handleTransfer(params: {
    fromAccountId: number;
    amount: number;
    transactedAt?: Date | null;
  }): Promise<void> {
    const result = await this.goalsListStore.transferToGoal({
      fromAccountId: params.fromAccountId,
      toAccountId: this.selectedGoal()!.id,
      amount: params.amount,
      transactedAt: params.transactedAt,
    });

    if (result.ok) {
      this.dialogVisible.set(false);
      void this.savingsOverviewStore.load();
      this.messageService.add({
        severity: 'success',
        summary: 'Transfer successful',
        detail: `Deposited to ${this.selectedGoal()!.name}`,
      });
    } else {
      this.messageService.add({
        severity: 'error',
        summary: 'Transfer failed',
        detail: 'Something went wrong. Please try again.',
      });
    }
  }
}
