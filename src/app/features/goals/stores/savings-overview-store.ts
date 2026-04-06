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
  selectedCurrencyCode: string | null;
  goalCurrencies: string[];
}

const initialState: SavingsOverviewState = {
  isLoading: false,
  isUpdating: false,
  isLoaded: false,
  isError: false,
  data: [],
  selectedYear: new Date(),
  selectedCurrencyCode: null,
  goalCurrencies: [],
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
    availableCurrencies: computed(() =>
      store.goalCurrencies().map((code) => ({ name: code })),
    ),
  })),

  withMethods((store, repository = inject(GoalsRepository)) => ({
    async load(): Promise<void> {
      const currencyCode = store.selectedCurrencyCode();
      if (!currencyCode) return;

      patchState(
        store,
        store.isLoaded() ? { isUpdating: true } : { isLoading: true },
        { isError: false },
      );

      try {
        const data = await repository.getSavingsOverview({
          year: store.selectedYear(),
          currencyCode,
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

    async loadCurrencies(): Promise<void> {
      const goals = await repository.getGoals();
      const unique = [...new Set(goals.map((g) => g.currencyCode))];
      const currentCode = store.selectedCurrencyCode();
      patchState(store, {
        goalCurrencies: unique,
        selectedCurrencyCode:
          currentCode != null && unique.includes(currentCode)
            ? currentCode
            : (unique[0] ?? null),
      });
    },
  })),

  withHooks({
    onInit(store) {
      untracked(() => store.loadCurrencies());

      effect(() => {
        store.selectedYear();
        store.selectedCurrencyCode();
        untracked(() => store.load());
      });
    },
  }),
);
