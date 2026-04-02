import { computed, effect, inject, untracked } from '@angular/core';
import { SavingsGoal } from '@core/models/savings-goal';
import {
  patchState,
  signalStore,
  withComputed,
  withHooks,
  withMethods,
  withState,
} from '@ngrx/signals';
import { GoalsRepository } from '../repositories/goals-repository';

interface TotalGoalsState {
  isLoading: boolean;
  isUpdating: boolean;
  isLoaded: boolean;
  isError: boolean;
  goals: SavingsGoal[];
  selectedYear: Date;
}

const initialState: TotalGoalsState = {
  isLoading: true,
  isUpdating: false,
  isLoaded: false,
  isError: false,
  goals: [],
  selectedYear: new Date(),
};

export const TotalGoalsStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

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

  withMethods((store, repository = inject(GoalsRepository)) => ({
    async loadGoals(): Promise<void> {
      patchState(
        store,
        store.isLoaded() ? { isUpdating: true } : { isLoading: true },
        { isError: false },
      );

      try {
        const goals = await repository.getGoals({ year: store.selectedYear() });
        patchState(store, {
          goals,
          isLoading: false,
          isUpdating: false,
          isLoaded: true,
        });
      } catch {
        patchState(store, {
          isLoading: false,
          isUpdating: false,
          isError: true,
        });
      }
    },

    updateYear: (year: Date) => patchState(store, { selectedYear: year }),
  })),

  withHooks({
    onInit(store) {
      effect(() => {
        store.selectedYear();
        untracked(() => store.loadGoals());
      });
    },
  }),
);
