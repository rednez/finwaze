import { computed, effect, inject, untracked } from '@angular/core';
import {
  MonthlySavingsOverview,
  GoalsRepository,
} from '../repositories/goals-repository';
import {
  patchState,
  signalStore,
  withComputed,
  withHooks,
  withMethods,
  withState,
} from '@ngrx/signals';

interface SavingsOverviewState {
  isLoading: boolean;
  isUpdating: boolean;
  isLoaded: boolean;
  isError: boolean;
  data: MonthlySavingsOverview[];
  selectedYear: Date;
  selectedCurrencyCode: string;
}

const initialState: SavingsOverviewState = {
  isLoading: false,
  isUpdating: false,
  isLoaded: false,
  isError: false,
  data: [],
  selectedYear: new Date(),
  selectedCurrencyCode: 'USD',
};

export const SavingsOverviewStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withComputed((store) => ({
    labels: computed(() => store.data().map((row) => row.month)),
    currentSavings: computed(() =>
      store.data().map((row) => row.currentYearAmount),
    ),
    previousSavings: computed(() =>
      store.data().map((row) => row.previousYearAmount),
    ),
  })),

  withMethods((store, repository = inject(GoalsRepository)) => ({
    async load(): Promise<void> {
      patchState(
        store,
        store.isLoaded() ? { isUpdating: true } : { isLoading: true },
        { isError: false },
      );

      try {
        const data = await repository.getSavingsOverview({
          year: store.selectedYear(),
          currencyCode: store.selectedCurrencyCode(),
        });

        patchState(store, {
          data,
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
    updateCurrencyCode: (code: string) =>
      patchState(store, { selectedCurrencyCode: code }),
  })),

  withHooks({
    onInit(store) {
      effect(() => {
        store.selectedYear();
        store.selectedCurrencyCode();
        untracked(() => store.load());
      });
    },
  }),
);
