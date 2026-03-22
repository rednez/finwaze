import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { Transaction } from '@core/models/transactions';
import { resultError, resultOk } from '@core/utils/result-factory';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';
import { TransactionsRepository } from '../repositories/transactions-repository';

export interface TransferDetailsState {
  isLoading: boolean;
  isDeleting: boolean;
  isError: boolean;
  transactionId: number | null;
  refTransactions: Transaction[];
}

const initialState: TransferDetailsState = {
  isLoading: false,
  isDeleting: false,
  isError: false,
  transactionId: null,
  refTransactions: [],
};

export const TransferDetailsStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withMethods((store, repository = inject(TransactionsRepository)) => ({
    async loadDetails(transactionId: number): Promise<Result> {
      patchState(store, () => ({
        isLoading: true,
      }));

      try {
        const refTransactions =
          await repository.getTransferTransactions(transactionId);

        patchState(store, () => ({
          isLoading: false,
          refTransactions,
          transactionId,
        }));

        return resultOk();
      } catch (error) {
        patchState(store, () => ({
          ...initialState,
          isError: true,
        }));

        return resultError(error);
      }
    },

    async deleteTransfers(): Promise<Result> {
      patchState(store, () => ({
        isDeleting: true,
      }));

      try {
        const transferId = store.refTransactions()[0].transferId;

        if (!transferId) {
          throw new Error('Transfer ID not found');
        }

        await repository.deleteTransferTransactions(transferId);

        patchState(store, () => ({
          isDeleting: false,
          refTransactions: [],
          transactionId: null,
        }));

        return resultOk();
      } catch (error) {
        patchState(store, () => ({
          isError: true,
        }));

        return resultError(error);
      }
    },
  })),
);
