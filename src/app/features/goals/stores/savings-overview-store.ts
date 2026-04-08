import { computed, effect, inject, untracked } from '@angular/core';
import {
  patchState,
  signalStore,
  withComputed,
  withHooks,
  withMethods,
  withProps,
  withState,
} from '@ngrx/signals';
import { MonthlySavingsOverview } from '../models';
import { GoalsRepository } from '../repositories/goals-repository';
import { GoalsListStore } from './goals-list-store';

interface SavingsOverviewState {
  isLoading: boolean;
  isUpdating: boolean;
  isLoaded: boolean;
  isError: boolean;
  data: MonthlySavingsOverview[];
  selectedCurrencyCode: string | null;
  goalCurrencies: string[];
}

const initialState: SavingsOverviewState = {
  isLoading: false,
  isUpdating: false,
  isLoaded: false,
  isError: false,
  data: [],
  selectedCurrencyCode: null,
  goalCurrencies: [],
};

export const SavingsOverviewStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withProps(() => ({
    goalsListStore: inject(GoalsListStore),
  })),

  withComputed((store) => ({
    labels: computed(() => store.data().map((row) => row.month)),
    currentSavings: computed(() =>
      store.data().map((row) => row.currentYearAmount),
    ),
    previousSavings: computed(() =>
      store.data().map((row) => row.previousYearAmount),
    ),
    availableCurrencies: computed(() => [
      ...new Set(
        store.goalsListStore.goals().map((g) => ({ name: g.currencyCode })),
      ),
    ]),
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
          year: store.goalsListStore.selectedYear(),
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

    updateCurrencyCode: (code: string) =>
      patchState(store, { selectedCurrencyCode: code }),
  })),

  withHooks({
    onInit(store) {
      effect(() => {
        store.selectedCurrencyCode();
        store.goalsListStore.selectedYear();
        untracked(() => store.load());
      });
    },
  }),
);
