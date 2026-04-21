import {
  ChangeDetectionStrategy,
  Component,
  inject,
  signal,
} from '@angular/core';
import { RouterLink } from '@angular/router';
import { SavingsGoal } from '@core/models/savings-goal';
import { LocalizationService } from '@core/services/localization.service';
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
import { WithdrawFromGoalDialog } from '../../ui/withdraw-from-goal-dialog/withdraw-from-goal-dialog';
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
    WithdrawFromGoalDialog,
    EmptyGoalsListState,
  ],
  providers: [MessageService],
  templateUrl: './goals.html',
  host: { class: 'flex flex-col gap-4' },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Goals {
  protected readonly accountsStore = inject(AccountsStore);
  protected readonly goalsListStore = inject(GoalsListStore);
  private readonly savingsOverviewStore = inject(SavingsOverviewStore);
  private readonly messageService = inject(MessageService);
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  protected readonly selectedGoal = signal<SavingsGoal | null>(null);
  protected readonly dialogVisible = signal(false);

  protected readonly selectedGoalForWithdraw = signal<SavingsGoal | null>(null);
  protected readonly withdrawDialogVisible = signal(false);

  protected openTransferDialog(goal: SavingsGoal): void {
    this.selectedGoal.set(goal);
    this.dialogVisible.set(true);
  }

  protected openWithdrawDialog(goal: SavingsGoal): void {
    this.selectedGoalForWithdraw.set(goal);
    this.withdrawDialogVisible.set(true);
  }

  protected async handleWithdraw(params: {
    toAccountId: number;
    amount: number;
    transactedAt?: Date | null;
  }): Promise<void> {
    const result = await this.goalsListStore.withdrawFromGoal({
      goalAccountId: this.selectedGoalForWithdraw()!.id,
      toAccountId: params.toAccountId,
      amount: params.amount,
      transactedAt: params.transactedAt,
    });

    if (result.ok) {
      await Promise.all([
        this.goalsListStore.loadGoals(),
        this.savingsOverviewStore.load(),
      ]);
      this.withdrawDialogVisible.set(false);
      this.messageService.add({
        severity: 'success',
        summary: this.t('goals.withdrawalSuccessful'),
        detail: `${this.t('goals.withdrawnFrom')} ${this.selectedGoalForWithdraw()!.name}`,
      });
    } else {
      this.messageService.add({
        severity: 'error',
        summary: this.t('goals.withdrawalFailed'),
        detail: this.t('shared.somethingWentWrong'),
      });
    }
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
        summary: this.t('goals.transferSuccessful'),
        detail: `${this.t('goals.depositedTo')} ${this.selectedGoal()!.name}`,
      });
    } else {
      this.messageService.add({
        severity: 'error',
        summary: this.t('goals.transferFailed'),
        detail: this.t('shared.somethingWentWrong'),
      });
    }
  }
}
