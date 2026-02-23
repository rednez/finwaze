import { inject } from '@angular/core';
import { toObservable } from '@angular/core/rxjs-interop';
import { Transaction } from '@core/models/transactions';
import { AccountsStore } from '@core/store/accounts-store';
import {
  patchState,
  signalStore,
  withComputed,
  withMethods,
  withProps,
  withState,
} from '@ngrx/signals';
import { filter } from 'rxjs';
import { MonthlyCashFlow, TotalSummaries } from '../models';
import { DashboardRepository } from '../repositories';
import { DashboardLoadingStateStore } from './dashboard-loading-state-store';

export interface DashboardState {
  totalsSummary: TotalSummaries;
  _cashFlow: MonthlyCashFlow[];
  recentTransactions: Transaction[];
}

const initialState: DashboardState = {
  totalsSummary: {
    totalBalance: 0,
    monthlyIncome: 0,
    monthlyExpense: 0,
    previousMonthTotalBalance: 0,
    previousMonthlyIncome: 0,
    previousMonthlyExpense: 0,
  },
  _cashFlow: [],
  recentTransactions: [],
};

export const DashboardStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withProps(() => ({
    repository: inject(DashboardRepository),
    accountsStore: inject(AccountsStore),
    loadingStore: inject(DashboardLoadingStateStore),
  })),

  withProps((store) => ({
    currencyCode$: toObservable(store.accountsStore.selectedCurrencyCode).pipe(
      filter(Boolean),
    ),
  })),

  withComputed((store) => ({
    isLoading: () =>
      store.loadingStore.isLoading() || store.accountsStore.isLoading(),
    isError: () => store.loadingStore.isError(),
    myCurrencies: () => store.accountsStore.myCurrencies(),
    selectedCurrencyCode: () => store.accountsStore.selectedCurrencyCode(),
    cashFlowMonths: () => store._cashFlow().map((item) => item.month),
    cashFlowIncomes: () => store._cashFlow().map((item) => item.income),
    cashFlowExpenses: () => store._cashFlow().map((item) => item.expense),
  })),

  withMethods((store) => ({
    async loadTotalsSummary(): Promise<void> {
      if (store.loadingStore.isLoaded()) {
        store.loadingStore.startUpdating();
      } else {
        store.loadingStore.startLoading();
      }

      try {
        if (!store.selectedCurrencyCode()) {
          throw new Error('Currency is not set');
        }

        const totalsSummary = await store.repository.getTotals(
          store.selectedCurrencyCode()!,
        );

        patchState(store, () => ({ totalsSummary }));

        if (store.loadingStore.isLoaded()) {
          store.loadingStore.successUpdating();
        } else {
          store.loadingStore.successLoading();
        }
      } catch (error) {
        if (store.loadingStore.isLoaded()) {
          store.loadingStore.errorUpdating();
        } else {
          store.loadingStore.errorLoading();
        }
      }
    },

    async loadCashFlow(): Promise<void> {
      if (store.loadingStore.isLoaded()) {
        store.loadingStore.startUpdating();
      } else {
        store.loadingStore.startLoading();
      }

      try {
        if (!store.selectedCurrencyCode()) {
          throw new Error('Currency is not set');
        }

        const cashFlow = await store.repository.getMonthlyCashFlow(
          store.selectedCurrencyCode()!,
          12,
        );

        patchState(store, () => ({ _cashFlow: cashFlow }));

        if (store.loadingStore.isLoaded()) {
          store.loadingStore.successUpdating();
        } else {
          store.loadingStore.successLoading();
        }
      } catch (error) {
        if (store.loadingStore.isLoaded()) {
          store.loadingStore.errorUpdating();
        } else {
          store.loadingStore.errorLoading();
        }
      }
    },

    async loadRecentTransactions(): Promise<void> {
      if (store.loadingStore.isLoaded()) {
        store.loadingStore.startUpdating();
      } else {
        store.loadingStore.startLoading();
      }

      try {
        if (!store.selectedCurrencyCode()) {
          throw new Error('Currency is not set');
        }

        const recentTransactions = await store.repository.getRecentTransactions(
          store.selectedCurrencyCode()!,
        );

        patchState(store, () => ({ recentTransactions }));

        if (store.loadingStore.isLoaded()) {
          store.loadingStore.successUpdating();
        } else {
          store.loadingStore.successLoading();
        }
      } catch (error) {
        if (store.loadingStore.isLoaded()) {
          store.loadingStore.errorUpdating();
        } else {
          store.loadingStore.errorLoading();
        }
      }
    },
  })),
);
