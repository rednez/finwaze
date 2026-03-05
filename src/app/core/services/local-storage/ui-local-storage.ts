import { Injectable } from '@angular/core';
import { UiExpenseTransactionForm, UiState } from '@core/models/ui-state';

const KEY = 'ui';

const initialValue: UiState = {
  expenseTransactionForm: {
    accountId: null,
    groupId: null,
    categoryId: null,
    transactionCurrencyCode: null,
    chargedCurrencyCode: null,
  },
};

@Injectable({
  providedIn: 'root',
})
export class UiLocalStorage {
  updateExpenseTransactionForm(data: Partial<UiExpenseTransactionForm>) {
    const store = this.parsedStore;

    localStorage.setItem(
      KEY,
      JSON.stringify({
        ...store,
        expenseTransactionForm: {
          ...store.expenseTransactionForm,
          ...data,
        },
      }),
    );
  }

  get parsedStore(): UiState {
    const item = localStorage.getItem(KEY);

    if (item) {
      try {
        const parsed = JSON.parse(item);
        return parsed as UiState;
      } catch {
        return initialValue;
      }
    } else {
      return initialValue;
    }
  }

  clear() {
    localStorage.removeItem(KEY);
  }
}
