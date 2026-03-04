import { Injectable } from '@angular/core';

const KEY = 'ui';

export interface UiLocalStorageState {
  recentSelection: {
    fromAccountId: number | null;
    toAccountId: number | null;
    groupId: number | null;
    categoryId: number | null;
    currencyCode: string | null;
  };
}

const initialValue: UiLocalStorageState = {
  recentSelection: {
    fromAccountId: null,
    toAccountId: null,
    groupId: null,
    categoryId: null,
    currencyCode: null,
  },
};

@Injectable({
  providedIn: 'root',
})
export class UiLocalStorage {
  updateRecentSelection(data: {
    fromAccountId?: number;
    toAccountId?: number;
    groupId?: number;
    categoryId?: number | null;
    currencyCode?: string;
  }) {
    const prevValue = this.parsedValue;

    localStorage.setItem(
      KEY,
      JSON.stringify({
        ...prevValue,
        recentSelection: {
          ...prevValue.recentSelection,
          ...data,
        },
      }),
    );
  }

  get parsedValue(): UiLocalStorageState {
    const item = localStorage.getItem(KEY);

    if (item) {
      try {
        const parsed = JSON.parse(item);
        return parsed as UiLocalStorageState;
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
