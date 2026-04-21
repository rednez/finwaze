import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  signal,
} from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { FormPageLayout } from '@core/layout/form-page-layout';
import { SavingsGoal } from '@core/models/savings-goal';
import { LocalizationService } from '@core/services/localization.service';
import { AccountsStore } from '@core/store/accounts-store';
import { CurrenciesStore } from '@core/store/currencies-store';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { ConfirmationService, MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { ToastModule } from 'primeng/toast';
import { GoalsRepository } from '../../repositories/goals-repository';
import { SavingsOverviewStore } from '../../stores';
import { GoalsListStore } from '../../stores/goals-list-store';
import { CancelGoalDialog } from '../../ui/cancel-goal-dialog';
import { CompleteGoalDialog } from '../../ui/complete-goal-dialog';
import { GoalForm, GoalFormData } from '../../ui/goal-form';
import { GoalNotFound } from './goal-not-found';

@Component({
  imports: [
    GoalForm,
    GoalNotFound,
    FormPageLayout,
    ToastModule,
    ProgressSpinnerModule,
    ButtonModule,
    ConfirmDialogModule,
    CancelGoalDialog,
    CompleteGoalDialog,
    TranslatePipe,
  ],
  templateUrl: './edit-goal.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [MessageService, ConfirmationService],
})
export class EditGoal {
  protected readonly goalsListStore = inject(GoalsListStore);
  private readonly savingsOverviewStore = inject(SavingsOverviewStore);
  protected readonly currenciesStore = inject(CurrenciesStore);
  private readonly accountsStore = inject(AccountsStore);
  private readonly goalsRepository = inject(GoalsRepository);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly messageService = inject(MessageService);
  private readonly confirmationService = inject(ConfirmationService);
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  protected readonly isEditMode = this.route.snapshot.url[0]?.path !== 'create';
  private readonly goalId = this.isEditMode
    ? Number(this.route.snapshot.paramMap.get('id'))
    : null;

  protected readonly goal = signal<SavingsGoal | null>(null);
  protected readonly isLoading = signal(this.isEditMode);
  protected readonly isGoalNotFound = signal(false);
  protected readonly cancelDialogVisible = signal(false);
  protected readonly doneDialogVisible = signal(false);

  protected readonly title = computed(() =>
    this.isEditMode ? this.t('goals.editGoal.editGoal') : 'New Goal',
  );

  protected readonly regularAccounts = computed(() =>
    this.accountsStore
      .accounts()
      .filter((a) => a.currencyCode === this.goal()?.currencyCode),
  );

  constructor() {
    if (this.isEditMode && this.goalId) {
      this.loadGoal(this.goalId);
    }
  }

  protected gotoBack() {
    this.router.navigate(['..'], { relativeTo: this.route });
  }

  protected async onSubmit(formData: GoalFormData) {
    if (this.isEditMode) {
      await this.updateGoal(formData);
    } else {
      await this.createGoal(formData);
    }
  }

  protected confirmCancel() {
    const goal = this.goal()!;

    if (goal.accumulatedAmount === 0) {
      this.confirmationService.confirm({
        message: 'Mark this goal as cancelled? This action cannot be undone.',
        header: 'Cancel Goal',
        icon: 'pi pi-exclamation-triangle',
        acceptLabel: 'Yes, cancel it',
        rejectLabel: 'Keep it',
        accept: () => this.cancelGoal(),
      });
    } else {
      this.cancelDialogVisible.set(true);
    }
  }

  protected async onCancelGoalConfirmed(event: { toAccountId: number }) {
    const goal = this.goal()!;
    const { error } = await this.goalsListStore.cancelGoalWithTransfer({
      goalAccountId: goal.id,
      toAccountId: event.toAccountId,
      amount: goal.accumulatedAmount,
    });

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Failed to cancel goal',
        detail: error.message,
      });
    } else {
      this.cancelDialogVisible.set(false);
      await this.loadGoalsAndOverview();
      this.gotoBack();
    }
  }

  protected confirmDone() {
    this.doneDialogVisible.set(true);
  }

  protected async onDoneGoalConfirmed(event: { toAccountId: number }) {
    const goal = this.goal()!;
    const { error } = await this.goalsListStore.markGoalAsDoneWithTransfer({
      goalAccountId: goal.id,
      toAccountId: event.toAccountId,
      amount: goal.accumulatedAmount,
    });

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Failed to complete goal',
        detail: error.message,
      });
    } else {
      this.doneDialogVisible.set(false);
      await this.loadGoalsAndOverview();
      this.gotoBack();
    }
  }

  protected confirmDelete() {
    this.confirmationService.confirm({
      message:
        'Delete this goal permanently? All associated transactions will also be deleted.',
      header: 'Delete Goal',
      icon: 'pi pi-exclamation-triangle',
      acceptLabel: 'Yes, delete',
      rejectLabel: 'Keep it',
      acceptButtonProps: { severity: 'danger' },
      accept: () => this.deleteGoal(),
    });
  }

  private async loadGoal(goalId: number) {
    this.isLoading.set(true);
    try {
      const goal = await this.goalsRepository.getGoalById(goalId);
      if (goal) {
        this.goal.set(goal);
      } else {
        this.isGoalNotFound.set(true);
      }
    } catch {
      this.isGoalNotFound.set(true);
    } finally {
      this.isLoading.set(false);
    }
  }

  private async createGoal(formData: GoalFormData) {
    const { error } = await this.goalsListStore.createGoal({
      name: formData.name,
      currencyId: formData.currencyId!,
      targetAmount: formData.targetAmount,
      targetDate: formData.targetDate,
    });

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Goal creation failed',
        detail: error.message,
      });
    } else {
      this.gotoBack();
    }
  }

  private async updateGoal(formData: GoalFormData) {
    const { error } = await this.goalsListStore.updateGoal({
      accountId: this.goal()!.id,
      name: formData.name,
      targetAmount: formData.targetAmount,
      targetDate: formData.targetDate,
    });

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Goal update failed',
        detail: error.message,
      });
    } else {
      const updated = await this.goalsRepository.getGoalById(this.goal()!.id);
      if (updated) this.goal.set(updated);
      this.messageService.add({
        severity: 'success',
        summary: 'Goal updated successfully',
      });

      this.loadGoalsAndOverview();
    }
  }

  private async cancelGoal() {
    const { error } = await this.goalsListStore.cancelGoal(this.goal()!.id);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Failed to cancel goal',
        detail: error.message,
      });
    } else {
      await this.loadGoalsAndOverview();
      this.gotoBack();
    }
  }

  private async deleteGoal() {
    const { error } = await this.goalsListStore.deleteGoal(this.goal()!.id);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Failed to delete goal',
        detail: error.message,
      });
    } else {
      await this.loadGoalsAndOverview();
      this.gotoBack();
    }
  }

  private async loadGoalsAndOverview() {
    await Promise.all([
      this.goalsListStore.loadGoals(),
      this.savingsOverviewStore.load(),
    ]);
  }
}
