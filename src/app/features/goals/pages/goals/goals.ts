import {
  ChangeDetectionStrategy,
  Component,
  inject,
  signal,
} from '@angular/core';
import { RouterLink } from '@angular/router';
import { SavingsGoal } from '@core/models/savings-goal';
import { AccountsStore } from '@core/store/accounts-store';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { SkeletonModule } from 'primeng/skeleton';
import { ToastModule } from 'primeng/toast';
import { GoalsListStore, SavingsOverviewStore } from '../../stores';
import { GoalCard } from '../../ui/goal-card/goal-card';
import { GoalsFilters } from '../../ui/goals-filters/goals-filters';
import { SavingsOverviewWidget } from '../../ui/savings-overview-widget/savings-overview-widget';
import { TotalGoalsCard } from '../../ui/total-goals-card/total-goals-card';
import { TransferToGoalDialog } from '../../ui/transfer-to-goal-dialog/transfer-to-goal-dialog';
import { EmptyGoalsListState } from './empty-goals-list-state';

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
    EmptyGoalsListState,
  ],
  providers: [MessageService],
  templateUrl: './goals.html',
  host: {
    class: 'flex flex-col gap-4',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Goals {
  protected readonly accountsStore = inject(AccountsStore);
  protected readonly goalsListStore = inject(GoalsListStore);
  private readonly savingsOverviewStore = inject(SavingsOverviewStore);
  private readonly messageService = inject(MessageService);

  protected readonly selectedGoal = signal<SavingsGoal | null>(null);
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
      await Promise.all([
        this.goalsListStore.loadGoals(),
        this.savingsOverviewStore.load(),
      ]);

      this.dialogVisible.set(false);

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
