import { inject } from '@angular/core';
import {
  UiExpenseTransactionForm,
  UiIncomeTransactionForm,
  UiState,
} from '@core/models/ui-state';
import { UiLocalStorage } from '@core/services/local-storage';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';

const initialState: UiState = {
  expenseTransactionForm: {
    accountId: null,
    groupId: null,
    categoryId: null,
    transactionCurrencyCode: null,
    chargedCurrencyCode: null,
  },
  incomeTransactionForm: {
    accountId: null,
    groupId: null,
    categoryId: null,
  },
};

export const UiStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withMethods((store, uiLocalStorage = inject(UiLocalStorage)) => ({
    restoreFromLocalStorage() {
      patchState(store, () => uiLocalStorage.parsedStore);
    },

    updateExpenseTransactionForm(data: Partial<UiExpenseTransactionForm>) {
      uiLocalStorage.updateExpenseTransactionForm(data);

      patchState(store, (state) => ({
        expenseTransactionForm: {
          ...state.expenseTransactionForm,
          ...data,
        },
      }));
    },

    updateIncomeTransactionForm(data: Partial<UiIncomeTransactionForm>) {
      uiLocalStorage.updateIncomeTransactionForm(data);

      patchState(store, (state) => ({
        incomeTransactionForm: {
          ...state.incomeTransactionForm,
          ...data,
        },
      }));
    },
  })),
);
