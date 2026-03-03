import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';

export interface UiState {
  recentSelection: {
    fromAccountId: number | null;
    toAccountId: number | null;
    groupId: number | null;
    categoryId: number | null;
    currencyCode: number | null;
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

  withMethods((store) => ({
    updateFromAccountId(id: number) {
      patchState(store, (state) => ({
        recentSelection: {
          ...state.recentSelection,
          fromAccountId: id,
        },
      }));
    },
    updateToAccountId(id: number) {
      patchState(store, (state) => ({
        recentSelection: {
          ...state.recentSelection,
          toAccountId: id,
        },
      }));
    },
    updateGroupId(id: number) {
      patchState(store, (state) => ({
        recentSelection: {
          ...state.recentSelection,
          groupId: id,
        },
      }));
    },
    updateCategoryId(id: number) {
      patchState(store, (state) => ({
        recentSelection: {
          ...state.recentSelection,
          categoryId: id,
        },
      }));
    },
    updateCurrencyCode(code: number) {
      patchState(store, (state) => ({
        recentSelection: {
          ...state.recentSelection,
          currencyCode: code,
        },
      }));
    },
  })),
);
