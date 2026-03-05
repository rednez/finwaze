import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { Transaction } from '@core/models/transactions';
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
import { ExpenseFormData } from '../pages/edit-transaction/ui/expense-form/expense-form';
import { TransactionsRepository } from '../repositories/transactions-repository';

export interface ExpenseTransactionState {
  isCreatingMode: boolean;
  isLoading: boolean;
  isCreating: boolean;
  isUpdating: boolean;
  selectedTransaction: Transaction | null;
}

const initialState: ExpenseTransactionState = {
  isCreatingMode: false,
  isLoading: false,
  isCreating: false,
  isUpdating: false,
  selectedTransaction: null,
};

export const ExpenseTransactionStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withProps((store) => ({
    uiStore: inject(UiStore),
  })),

  withComputed(
    (
      _,
      accountsStore = inject(AccountsStore),
      categoriesStore = inject(CategoriesStore),
    ) => ({
      currencies: () => accountsStore.myCurrencies(),
      groups: () => categoriesStore.allGroups(),
      categories: () => categoriesStore.allCategories(),
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
            transactionAmount: formData.transactionAmount * -1,
            transactionCurrencyId: currenciesStore.findByCode(
              formData.transactionCurrencyCode,
            )!.id,
            chargedAmount: formData.chargedAmount * -1,
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
          if (!store.selectedTransaction()) {
            throw new Error('No transaction selected');
          }

          await repository.updateExpenseTransaction(
            store.selectedTransaction()?.id!,
            {
              transactedAt: formData.transactedAt,
              accountId: formData.accountId,
              categoryId: formData.categoryId,
              transactionAmount: formData.transactionAmount * -1,
              transactionCurrencyId: currenciesStore.findByCode(
                formData.transactionCurrencyCode,
              )!.id,
              chargedAmount: formData.chargedAmount * -1,
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

      async loadTransactionDetails(transactionId: number): Promise<Result> {
        patchState(store, () => ({
          isLoading: true,
        }));

        try {
          const data = await repository.getTransactionDetails(transactionId);

          patchState(store, () => ({
            isLoading: false,
            selectedTransaction: data,
          }));

          return resultOk();
        } catch (error: any) {
          patchState(store, () => ({
            isLoading: false,
          }));

          return resultError(error);
        }
      },

      updateIsCreatingMode(isCreatingMode: boolean): void {
        patchState(store, () => ({
          isCreatingMode,
        }));
      },

      updateSelectedTransaction(data: Transaction): void {
        patchState(store, () => ({
          selectedTransaction: data,
        }));
      },

      reset(): void {
        patchState(store, () => initialState);
      },
    }),
  ),
);
