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
  withState,
  withProps,
} from '@ngrx/signals';
import { ExpenseFormData } from '../pages/edit-transaction/ui/expense-form/expense-form';
import { TransactionsRepository } from '../repositories/transactions-repository';
import { TransactionsStore } from './transactions-store';

export interface ExpenseTransactionState {
  isCreatingMode: boolean;
  isCreating: boolean;
  isUpdating: boolean;
  selectedTransactionId: number | null;
}

const initialState: ExpenseTransactionState = {
  isCreatingMode: false,
  isCreating: false,
  isUpdating: false,
  selectedTransactionId: null,
};

export const ExpenseTransactionStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withProps((store) => ({
    uiStore: inject(UiStore),
  })),

  withComputed(
    (
      store,
      accountsStore = inject(AccountsStore),
      categoriesStore = inject(CategoriesStore),
      transactionsStore = inject(TransactionsStore),
    ) => ({
      currencies: () => accountsStore.myCurrencies(),
      groups: () => categoriesStore.allGroups(),
      categories: () => categoriesStore.allCategories(),
      selectedTransaction: () =>
        transactionsStore
          .transactions()
          .find((t) => t.id === store.selectedTransactionId()),
    }),
  ),

  withComputed((store) => ({
    initialFormValues: () => {
      if (store.isCreatingMode()) {
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
        const transaction = store.selectedTransaction();
        if (transaction) {
          return {
            accountId: transaction.account.id,
            groupId: transaction.group.id,
            categoryId: transaction.category.id,
            transactedAt: transaction.transactedAt,
            comment: transaction.comment || undefined,
            transactionAmount: transaction.transactionAmount,
            transactionCurrencyCode: transaction.transactionCurrency,
            chargedAmount: transaction.chargedAmount,
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
        } catch (error: any) {
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
          if (!store.selectedTransactionId()) {
            throw new Error('No transaction selected');
          }

          await repository.updateExpenseTransaction(
            store.selectedTransactionId()!,
            {
              transactedAt: formData.transactedAt,
              accountId: formData.accountId,
              categoryId: formData.categoryId,
              transactionAmount: formData.transactionAmount,
              transactionCurrencyId: currenciesStore.findByCode(
                formData.transactionCurrencyCode,
              )!.id,
              chargedAmount: formData.chargedAmount,
              comment: formData.comment,
            },
          );

          patchState(store, () => ({
            isUpdating: false,
          }));

          return resultOk();
        } catch (error: any) {
          patchState(store, () => ({
            isUpdating: false,
          }));

          return resultError(error);
        }
      },

      updateIsCreatingMode(isCreatingMode: boolean): void {
        patchState(store, () => ({
          isCreatingMode,
        }));
      },

      updateSelectedTransaction(id: number): void {
        patchState(store, () => ({
          selectedTransactionId: id,
        }));
      },

      reset(): void {
        patchState(store, () => initialState);
      },
    }),
  ),
);
