import { effect, inject, untracked } from '@angular/core';
import {
  patchState,
  signalStore,
  withHooks,
  withMethods,
  withState,
} from '@ngrx/signals';
import { FinancialSummary } from '../models';
import { AnalyticsRepository } from '../repositories';

interface AnalyticsState {
  isLoading: boolean;
  isLoaded: boolean;
  isUpdating: boolean;
  isError: boolean;
  selectedMonth: Date;
  selectedCurrencyCode: string;
  selectedAccountIds: number[];
  financialSummary: FinancialSummary | null;
}

const initialState: AnalyticsState = {
  isLoading: true,
  isLoaded: false,
  isUpdating: false,
  isError: false,
  selectedMonth: new Date(),
  selectedCurrencyCode: '',
  selectedAccountIds: [],
  financialSummary: null,
};

export const AnalyticsStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withMethods((store, repository = inject(AnalyticsRepository)) => ({
    async loadFinancialSummary(): Promise<void> {
      patchState(
        store,
        store.isLoaded() ? { isUpdating: true } : { isLoading: true },
        { isError: false },
      );

      try {
        const financialSummary = await repository.getFinancialSummary(
          store.selectedMonth(),
          store.selectedCurrencyCode(),
          store.selectedAccountIds(),
        );

        patchState(store, {
          financialSummary,
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

    updateMonth: (month: Date) => patchState(store, { selectedMonth: month }),

    updateCurrencyCode: (code: string) =>
      patchState(store, { selectedCurrencyCode: code }),

    updateAccountIds: (ids: number[]) =>
      patchState(store, { selectedAccountIds: ids }),
  })),

  withHooks({
    onInit(store) {
      effect(() => {
        store.selectedMonth();
        store.selectedCurrencyCode();
        store.selectedAccountIds();
        untracked(() => {
          if (store.selectedCurrencyCode()) store.loadFinancialSummary();
        });
      });
    },
  }),
);
