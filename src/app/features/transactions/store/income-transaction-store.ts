import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { Transaction } from '@core/models/transactions';
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
import { IncomeFormData } from '../models';
import { TransactionsRepository } from '../repositories/transactions-repository';
import { SelectedTransactionStore } from './selected-transaction-store';

export interface IncomeTransactionState {
  isCreating: boolean;
  isUpdating: boolean;
  selectedTransaction: Transaction | null;
}

const initialState: IncomeTransactionState = {
  isCreating: false,
  isUpdating: false,
  selectedTransaction: null,
};

export const IncomeTransactionStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withProps(() => ({
    uiStore: inject(UiStore),
    selectedTransactionStore: inject(SelectedTransactionStore),
  })),

  withComputed((_, categoriesStore = inject(CategoriesStore)) => ({
    groups: () => categoriesStore.incomeGroups(),
    categories: () => categoriesStore.allCategories(),
  })),

  withComputed((store) => ({
    initialFormValues: () => {
      if (store.selectedTransactionStore.isCreatingMode()) {
        return {
          accountId:
            store.uiStore.incomeTransactionForm().accountId || undefined,
          groupId: store.uiStore.incomeTransactionForm().groupId || undefined,
          categoryId:
            store.uiStore.incomeTransactionForm().categoryId || undefined,
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
            amount: transaction.transactionAmount,
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
      async createTransaction(formData: IncomeFormData): Promise<Result> {
        patchState(store, () => ({
          isCreating: true,
        }));

        try {
          await repository.createIncomeTransaction({
            transactedAt: formData.transactedAt,
            accountId: formData.accountId,
            categoryId: formData.categoryId,
            amount: formData.amount,
            currencyId: currenciesStore.findByCode(formData.currencyCode)!.id,
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

      async updateTransaction(formData: IncomeFormData): Promise<Result> {
        patchState(store, () => ({
          isUpdating: true,
        }));

        try {
          const selectedTransaction =
            store.selectedTransactionStore.transaction();

          if (!selectedTransaction) {
            throw new Error('No transaction selected');
          }

          await repository.updateIncomeTransaction(selectedTransaction.id, {
            transactedAt: formData.transactedAt,
            accountId: formData.accountId,
            categoryId: formData.categoryId,
            amount: formData.amount,
            currencyId: currenciesStore.findByCode(formData.currencyCode)!.id,
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
