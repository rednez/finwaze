import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { AccountsStore } from '@core/store/accounts-store';
import { CategoriesStore } from '@core/store/categories-store';
import { CurrenciesStore } from '@core/store/currencies-store';
import { UiStore } from '@core/store/ui-store';
import { resultError, resultOk } from '@core/utils/result-factory';
import {
  patchState,
  signalStore,
  withComputed,
  withMethods,
  withProps,
  withState,
} from '@ngrx/signals';
import { ExpenseFormData } from '../models';
import { TransactionsRepository } from '../repositories/transactions-repository';
import { SelectedTransactionStore } from './selected-transaction-store';

export interface ExpenseTransactionState {
  isCreating: boolean;
  isUpdating: boolean;
}

const initialState: ExpenseTransactionState = {
  isCreating: false,
  isUpdating: false,
};

export const ExpenseTransactionStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withProps(() => ({
    uiStore: inject(UiStore),
    selectedTransactionStore: inject(SelectedTransactionStore),
  })),

  withComputed(
    (
      _,
      accountsStore = inject(AccountsStore),
      categoriesStore = inject(CategoriesStore),
    ) => ({
      currencies: () => accountsStore.myCurrencies(),
      groups: () => categoriesStore.expensesGroups(),
      categories: () => categoriesStore.allCategories(),
    }),
  ),

  withComputed((store) => ({
    initialFormValues: () => {
      if (store.selectedTransactionStore.isCreatingMode()) {
        return {
          accountId:
            store.uiStore.expenseTransactionForm().accountId || undefined,
          groupId: store.uiStore.expenseTransactionForm().groupId || undefined,
          categoryId:
            store.uiStore.expenseTransactionForm().categoryId || undefined,
          transactionCurrencyCode:
            store.uiStore.expenseTransactionForm().transactionCurrencyCode ||
            undefined,
        };
      } else {
        const transaction = store.selectedTransactionStore.transaction();
        if (transaction) {
          return {
            accountId: transaction.account.id,
            groupId: transaction.group.id,
            categoryId: transaction.category.id,
            transactedAt: transaction.transactedAt,
            comment: transaction.comment || undefined,
            transactionAmount: Math.abs(transaction.transactionAmount),
            transactionCurrencyCode: transaction.transactionCurrency,
            chargedAmount: Math.abs(transaction.chargedAmount),
          };
        } else {
          return undefined;
        }
      }
    },
  })),

  withMethods(
    (
      store,
      repository = inject(TransactionsRepository),
      currenciesStore = inject(CurrenciesStore),
    ) => ({
      async createTransaction(formData: ExpenseFormData): Promise<Result> {
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
              formData.transactionCurrencyCode,
            )!.id,
            chargedAmount: formData.chargedAmount,
            comment: formData.comment,
          });

          patchState(store, () => ({
            isCreating: false,
          }));

          return resultOk();
        } catch (error) {
          patchState(store, () => ({
            isCreating: false,
          }));

          return resultError(error);
        }
      },

      async updateTransaction(formData: ExpenseFormData): Promise<Result> {
        patchState(store, () => ({
          isUpdating: true,
        }));

        try {
          const selectedTransaction =
            store.selectedTransactionStore.transaction();

          if (!selectedTransaction) {
            throw new Error('No transaction selected');
          }

          await repository.updateExpenseTransaction(selectedTransaction.id, {
            transactedAt: formData.transactedAt,
            accountId: formData.accountId,
            categoryId: formData.categoryId,
            transactionAmount: formData.transactionAmount,
            transactionCurrencyId: currenciesStore.findByCode(
              formData.transactionCurrencyCode,
            )!.id,
            chargedAmount: formData.chargedAmount,
            comment: formData.comment,
          });

          patchState(store, () => ({
            isUpdating: false,
          }));

          return resultOk();
        } catch (error) {
          patchState(store, () => ({
            isUpdating: false,
          }));

          return resultError(error);
        }
      },
    }),
  ),
);
