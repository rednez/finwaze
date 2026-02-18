import { inject } from '@angular/core';
import { toObservable } from '@angular/core/rxjs-interop';
import { Transaction } from '@core/models/transactions';
import { AccountsStore } from '@core/store/accounts-store';
import { CurrenciesStore } from '@core/store/currencies-store';
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
    currenciesStore: inject(CurrenciesStore),
    loadingStore: inject(DashboardLoadingStateStore),
  })),

  withProps((store) => ({
    currencyCode$: toObservable(store.currenciesStore.selectedCode).pipe(
      filter(Boolean),
    ),
  })),

  withComputed((store) => ({
    isTotalsSummaryLoading: () =>
      store.loadingStore.isTotalsSummaryLoading() ||
      store.currenciesStore.isLoading() ||
      store.accountsStore.isLoading(),
    isTotalsSummaryError: () => store.loadingStore.isTotalsSummaryError(),
    myCurrencies: () => store.accountsStore.myCurrencies(),
    selectedCurrencyCode: () => store.currenciesStore.selectedCode(),
    cashFlowMonths: () => store._cashFlow().map((item) => item.month),
    cashFlowIncomes: () => store._cashFlow().map((item) => item.income),
    cashFlowExpenses: () => store._cashFlow().map((item) => item.expense),
  })),

  withMethods((store) => ({
    async loadTotalsSummary(): Promise<void> {
      store.loadingStore.startTotalsSummaryLoading();

      try {
        if (!store.selectedCurrencyCode()) {
          throw new Error('Currency is not set');
        }

        const totalsSummary = await store.repository.getTotals(
          store.selectedCurrencyCode()!,
        );

        patchState(store, () => ({ totalsSummary }));
        store.loadingStore.successTotalsSummaryLoading();
      } catch (error) {
        store.loadingStore.errorTotalsSummaryLoading();
      }
    },

    async loadCashFlow(): Promise<void> {
      store.loadingStore.startCashFlowLoading();

      try {
        if (!store.selectedCurrencyCode()) {
          throw new Error('Currency is not set');
        }

        const cashFlow = await store.repository.getMonthlyCashFlow(
          store.selectedCurrencyCode()!,
          12,
        );

        patchState(store, () => ({ _cashFlow: cashFlow }));
        store.loadingStore.successCashFlowLoading();
      } catch (error) {
        store.loadingStore.errorCashFlowLoading();
      }
    },

    async loadRecentTransactions(): Promise<void> {
      store.loadingStore.startRecentTransactionsLoading();

      try {
        if (!store.selectedCurrencyCode()) {
          throw new Error('Currency is not set');
        }

        const recentTransactions = await store.repository.getRecentTransactions(
          store.selectedCurrencyCode()!,
        );

        patchState(store, () => ({ recentTransactions }));
        store.loadingStore.successRecentTransactionsLoading();
      } catch (error) {
        store.loadingStore.errorRecentTransactionsLoading();
      }
    },
  })),
);
