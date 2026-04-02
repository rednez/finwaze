import { effect, inject, untracked } from '@angular/core';
import { GoalStatus, SavingsGoal } from '@core/models/savings-goal';
import { Result } from '@core/models/result';
import { resultError, resultOk } from '@core/utils/result-factory';
import {
  patchState,
  signalStore,
  withHooks,
  withMethods,
  withState,
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
  isLoading: true,
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

  withMethods((store, repository = inject(GoalsRepository)) => ({
    async loadGoals(): Promise<Result> {
      if (store.isLoaded()) {
        patchState(store, { isUpdating: true });
      } else {
        patchState(store, { isLoading: true });
      }
      patchState(store, { isError: false });

      try {
        const goals = await repository.getGoals({
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
