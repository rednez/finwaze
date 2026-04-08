import { computed, effect, inject, untracked } from '@angular/core';
import { Result } from '@core/models/result';
import { GoalStatus, SavingsGoal } from '@core/models/savings-goal';
import { resultError, resultOk } from '@core/utils/result-factory';
import {
  patchState,
  signalStore,
  withComputed,
  withMethods,
  withHooks,
  withState,
  withProps,
} from '@ngrx/signals';
import { GoalsRepository } from '../repositories/goals-repository';

interface GoalsListState {
  isLoading: boolean;
  isUpdating: boolean;
  isLoaded: boolean;
  isError: boolean;
  goals: SavingsGoal[];
  selectedYear: Date;
  selectedStatus: GoalStatus | null;
}

const initialState: GoalsListState = {
  isLoading: false,
  isLoaded: false,
  isUpdating: false,
  isError: false,
  goals: [],
  selectedYear: new Date(),
  selectedStatus: null,
};

export const GoalsListStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withProps(() => ({
    repository: inject(GoalsRepository),
  })),

  withComputed((store) => ({
    totalCount: computed(() => store.goals().length),
    notStartedCount: computed(
      () => store.goals().filter((g) => g.status === 'notStarted').length,
    ),
    inProgressCount: computed(
      () => store.goals().filter((g) => g.status === 'inProgress').length,
    ),
    cancelledCount: computed(
      () => store.goals().filter((g) => g.status === 'cancelled').length,
    ),
    doneCount: computed(
      () => store.goals().filter((g) => g.status === 'done').length,
    ),
  })),

  withMethods((store) => ({
    async loadGoals(): Promise<Result> {
      if (store.isLoaded()) {
        patchState(store, { isUpdating: true });
      } else {
        patchState(store, { isLoading: true });
      }
      patchState(store, { isError: false });

      try {
        const goals = await store.repository.getGoals({
          year: store.selectedYear(),
          status: store.selectedStatus(),
        });

        patchState(store, {
          isLoading: false,
          isUpdating: false,
          isLoaded: true,
          goals,
        });

        return resultOk();
      } catch (error) {
        patchState(store, {
          isLoading: false,
          isUpdating: false,
          isError: true,
        });

        return resultError(error);
      }
    },

    updateYear: (year: Date) => patchState(store, { selectedYear: year }),

    updateStatus: (status: GoalStatus | null) =>
      patchState(store, { selectedStatus: status }),
  })),

  withMethods((store) => ({
    async createGoal(params: {
      name: string;
      currencyId: number;
      targetAmount: number;
      targetDate: Date;
    }): Promise<Result> {
      patchState(store, { isUpdating: true, isError: false });
      try {
        await store.repository.createGoal(params);
        await store.loadGoals();

        return resultOk();
      } catch (error) {
        patchState(store, { isUpdating: false, isError: true });
        return resultError(error);
      }
    },

    async updateGoal(params: {
      accountId: number;
      name: string;
      targetAmount: number;
      targetDate: Date;
    }): Promise<Result> {
      patchState(store, { isUpdating: true, isError: false });
      try {
        await store.repository.updateGoal(params);

        return resultOk();
      } catch (error) {
        patchState(store, { isUpdating: false, isError: true });
        return resultError(error);
      }
    },

    async cancelGoal(accountId: number): Promise<Result> {
      patchState(store, { isUpdating: true, isError: false });
      try {
        await store.repository.cancelGoal(accountId);

        return resultOk();
      } catch (error) {
        patchState(store, { isUpdating: false, isError: true });
        return resultError(error);
      }
    },

    async deleteGoal(accountId: number): Promise<Result> {
      patchState(store, { isUpdating: true, isError: false });
      try {
        await store.repository.deleteGoal(accountId);

        return resultOk();
      } catch (error) {
        patchState(store, { isUpdating: false, isError: true });
        return resultError(error);
      }
    },

    async transferToGoal(params: {
      fromAccountId: number;
      toAccountId: number;
      amount: number;
      transactedAt?: Date | null;
    }): Promise<Result> {
      patchState(store, { isUpdating: true, isError: false });
      try {
        await store.repository.transferToGoal(params);

        return resultOk();
      } catch (error) {
        patchState(store, { isUpdating: false, isError: true });
        return resultError(error);
      }
    },

    async cancelGoalWithTransfer(params: {
      goalAccountId: number;
      toAccountId: number;
      amount: number;
    }): Promise<Result> {
      patchState(store, { isUpdating: true, isError: false });
      try {
        await store.repository.transferToGoal({
          fromAccountId: params.goalAccountId,
          toAccountId: params.toAccountId,
          amount: params.amount,
        });
        await store.repository.cancelGoal(params.goalAccountId);

        return resultOk();
      } catch (error) {
        patchState(store, { isUpdating: false, isError: true });
        return resultError(error);
      }
    },
  })),

  withHooks({
    onInit(store) {
      effect(() => {
        store.selectedYear();
        store.selectedStatus();
        untracked(() => store.loadGoals());
      });
    },
  }),
);
