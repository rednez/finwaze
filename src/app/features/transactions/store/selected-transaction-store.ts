import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { Transaction } from '@core/models/transactions';
import { resultError, resultOk } from '@core/utils/result-factory';
import {
  patchState,
  signalStore,
  withMethods,
  withState,
  withComputed,
} from '@ngrx/signals';
import { TransactionsRepository } from '../repositories/transactions-repository';
import { waitFormMs } from '@shared/utils/wait-for-ms';

export interface SelectedTransactionState {
  isLoading: boolean;
  isCreatingMode: boolean;
  isDeleting: boolean;
  transaction: Transaction | null;
}

const initialState: SelectedTransactionState = {
  isLoading: false,
  isCreatingMode: false,
  isDeleting: false,
  transaction: null,
};

export const SelectedTransactionStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withComputed((store) => ({
    isExpense: () => store.transaction()?.type === 'expense',
    isIncome: () => store.transaction()?.type === 'income',
    shouldLoad: () => !store.isCreatingMode() && !store.transaction(),
  })),

  withMethods((store, repository = inject(TransactionsRepository)) => ({
    async loadTransaction(transactionId: number): Promise<Result> {
      patchState(store, () => ({
        isLoading: true,
      }));

      try {
        const data = await repository.getTransactionDetails(transactionId);

        await waitFormMs();

        patchState(store, () => ({
          isLoading: false,
          transaction: data,
        }));

        return resultOk();
      } catch (error) {
        patchState(store, () => ({
          isLoading: false,
        }));

        return resultError(error);
      }
    },

    async deleteTransaction(): Promise<Result> {
      patchState(store, () => ({
        isDeleting: true,
      }));

      try {
        const transaction = store.transaction();

        if (!transaction) {
          throw new Error('No transaction selected');
        }

        await repository.deleteTransaction(transaction.id);

        patchState(store, () => ({
          isDeleting: false,
          transaction: null,
        }));

        return resultOk();
      } catch (error) {
        patchState(store, () => ({
          isDeleting: false,
        }));

        return resultError(error);
      }
    },

    updateTransaction(data: Transaction) {
      patchState(store, () => ({ transaction: data }));
    },

    updateIsCreatingMode(isCreatingMode: boolean): void {
      patchState(store, () => ({
        isCreatingMode,
      }));
    },
  })),
);
