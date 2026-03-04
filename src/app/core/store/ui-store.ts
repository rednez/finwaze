import { inject } from '@angular/core';
import { UiLocalStorage } from '@core/services/local-storage';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';

export interface UiState {
  recentSelection: {
    fromAccountId: number | null;
    toAccountId: number | null;
    groupId: number | null;
    categoryId: number | null;
    currencyCode: string | null;
  };
}

const initialState: UiState = {
  recentSelection: {
    fromAccountId: null,
    toAccountId: null,
    groupId: null,
    categoryId: null,
    currencyCode: null,
  },
};

export const UiStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withMethods((store, uiLocalStorage = inject(UiLocalStorage)) => ({
    restoreFromLocalStorage() {
      patchState(store, () => ({
        recentSelection: uiLocalStorage.parsedValue.recentSelection,
      }));
    },

    updateFromAccountId(id: number) {
      uiLocalStorage.updateRecentSelection({ fromAccountId: id });

      patchState(store, (state) => ({
        recentSelection: {
          ...state.recentSelection,
          fromAccountId: id,
        },
      }));
    },

    updateToAccountId(id: number) {
      uiLocalStorage.updateRecentSelection({ toAccountId: id });
      patchState(store, (state) => ({
        recentSelection: {
          ...state.recentSelection,
          toAccountId: id,
        },
      }));
    },

    updateGroupId(id: number) {
      uiLocalStorage.updateRecentSelection({ groupId: id });
      patchState(store, (state) => ({
        recentSelection: {
          ...state.recentSelection,
          groupId: id,
        },
      }));
    },

    updateCategoryId(id: number | null) {
      uiLocalStorage.updateRecentSelection({ categoryId: id });
      patchState(store, (state) => ({
        recentSelection: {
          ...state.recentSelection,
          categoryId: id,
        },
      }));
    },

    updateCurrencyCode(code: string) {
      uiLocalStorage.updateRecentSelection({ currencyCode: code });
      patchState(store, (state) => ({
        recentSelection: {
          ...state.recentSelection,
          currencyCode: code,
        },
      }));
    },
  })),
);
