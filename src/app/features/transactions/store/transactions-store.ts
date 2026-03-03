import { inject } from '@angular/core';
import { Transaction } from '@core/models/transactions';
import { AccountsStore } from '@core/store/accounts-store';
import { CategoriesStore } from '@core/store/categories-store';
import { CurrenciesStore } from '@core/store/currencies-store';
import {
  patchState,
  signalStore,
  withComputed,
  withMethods,
  withState,
} from '@ngrx/signals';
import { ExpenseFormData } from '../pages/edit-transaction/ui/expense-form/expense-form';
import { TransactionsRepository } from '../repositories/transactions-repository';
import { Result } from '@core/models/result';
import { resultError, resultOk } from '@core/utils/result-factory';

export interface DashboardState {
  isLoading: boolean;
  isLoaded: boolean;
  isUpdating: boolean;
  isCreating: boolean;
  isError: boolean;
  transactions: Transaction[];
  month: Date;
  currencyCode: string | null;
  groupId: number | null;
  categoryId: number | null;
  selectedTransactionId: number | null;
}

const initialState: DashboardState = {
  isLoading: false,
  isLoaded: false,
  isUpdating: false,
  isCreating: false,
  isError: false,
  transactions: [],
  month: new Date(),
  currencyCode: null,
  groupId: null,
  categoryId: null,
  selectedTransactionId: null,
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

      selectedTransaction: () =>
        store
          .transactions()
          .find((t) => t.id === store.selectedTransactionId()),
    }),
  ),

  withComputed((store) => ({
    categoryIds: () =>
      store.categoryId()
        ? [store.categoryId()!]
        : store.categories().map((c) => c.id),
  })),

  withMethods(
    (
      store,
      repository = inject(TransactionsRepository),
      currenciesStore = inject(CurrenciesStore),
    ) => ({
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

      async createExpenseTransaction(
        formData: ExpenseFormData,
      ): Promise<Result> {
        patchState(store, () => ({
          isCreating: true,
        }));

        try {
          await repository.createExpenseTransaction({
            transactedAt: formData.transactedAt,
            accountId: formData.accountId,
            categoryId: formData.categoryId,
            transactionAmount: formData.transactionAmount,
            transactionCurrencyId: currenciesStore.findByCode(
              formData.transactionCurrency,
            )!.id,
            chargedAmount: formData.chargedAmount,
            comment: formData.comment,
          });

          patchState(store, () => ({
            isCreating: false,
          }));

          return resultOk();
        } catch (error: any) {
          patchState(store, () => ({
            isCreating: false,
          }));

          return resultError(error);
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

      selectTransaction(id: number): void {
        patchState(store, () => ({
          selectedTransactionId: id,
        }));
      },

      deselectTransaction(): void {
        patchState(store, () => ({
          selectedTransactionId: null,
        }));
      },

      markAsNotLoaded(): void {
        patchState(store, () => ({
          isLoaded: false,
        }));
      },
    }),
  ),
);
