import { inject } from '@angular/core';
import { Transaction } from '@core/models/transactions';
import { AccountsStore } from '@core/store/accounts-store';
import { CategoriesStore } from '@core/store/categories-store';
import {
  patchState,
  signalStore,
  withComputed,
  withMethods,
  withState,
} from '@ngrx/signals';
import { TransactionsRepository } from '../repositories/transactions-repository';

export interface DashboardState {
  isLoading: boolean;
  isLoaded: boolean;
  isUpdating: boolean;
  isError: boolean;
  transactions: Transaction[];
  month: Date;
  currencyCode: string | null;
  groupId: number | null;
  categoryId: number | null;
}

const initialState: DashboardState = {
  isLoading: false,
  isLoaded: false,
  isUpdating: false,
  isError: false,
  transactions: [],
  month: new Date(),
  currencyCode: null,
  groupId: null,
  categoryId: null,
};

export const TransactionsStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withComputed(
    (
      store,
      accountsStore = inject(AccountsStore),
      categoriesStore = inject(CategoriesStore),
    ) => ({
      currencies: () => accountsStore.myCurrencies(),
      groups: () => categoriesStore.allGroups(),
      categories: () =>
        categoriesStore
          .allCategories()
          .filter((c) => c.groupId === store.groupId()),
    }),
  ),

  withComputed((store) => ({
    categoryIds: () =>
      store.categoryId()
        ? [store.categoryId()!]
        : store.categories().map((c) => c.id),
  })),

  withMethods((store, repository = inject(TransactionsRepository)) => ({
    async loadTransactions(): Promise<void> {
      if (store.isLoaded()) {
        patchState(store, () => ({
          isUpdating: true,
        }));
      } else {
        patchState(store, () => ({
          isLoading: true,
        }));
      }

      try {
        const data = await repository.getFilteredTransactions({
          month: store.month(),
          categoryIds: store.categoryIds(),
          transactionCurrencyCode: store.currencyCode(),
        });

        if (store.isLoaded()) {
          patchState(store, () => ({
            isUpdating: false,
            transactions: data,
          }));
        } else {
          patchState(store, () => ({
            isLoading: false,
            isLoaded: true,
            transactions: data,
          }));
        }
      } catch (error) {
        patchState(store, () => ({
          ...initialState,
          isError: true,
        }));
      }
    },

    updateMonth(month: Date) {
      patchState(store, () => ({ month }));
    },

    updateCurrency(code: string | null) {
      patchState(store, () => ({ currencyCode: code }));
    },

    updateGroup(id: number | null): void {
      patchState(store, () => ({
        groupId: id,
        categoryId: null,
      }));
    },

    updateCategory(id: number | null): void {
      patchState(store, () => ({
        categoryId: id,
      }));
    },
  })),
);
