import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { Transaction } from '@core/models/transactions';
import { resultError, resultOk } from '@core/utils/result-factory';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';
import { WalletRepository } from '../repositories';

interface WalletRecentTransactionsState {
  isLoading: boolean;
  isError: boolean;
  data: Transaction[];
  currencyCode: string | null;
}

const initialState: WalletRecentTransactionsState = {
  isLoading: false,
  isError: false,
  data: [],
  currencyCode: null,
};

export const WalletRecentTransactionsStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withMethods((store, repository = inject(WalletRepository)) => ({
    async loadTransactions(): Promise<Result> {
      patchState(store, () => ({
        isLoading: true,
      }));

      try {
        if (!store.currencyCode()) {
          throw new Error('Currency code is not selected');
        }

        const data = await repository.getRecentTransactions(
          store.currencyCode()!,
        );

        patchState(store, () => ({
          isLoading: false,
          data,
        }));

        return resultOk();
      } catch (error: any) {
        patchState(store, () => ({
          ...initialState,
          isError: true,
        }));

        return resultError(error);
      }
    },

    updateCurrencyCode(currencyCode: string): void {
      patchState(store, () => ({
        currencyCode,
      }));
    },
  })),
);
