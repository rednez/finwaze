import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { resultError, resultOk } from '@core/utils/result-factory';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';
import { TransactionCashFlowItem } from '../models';
import { WalletRepository } from '../repositories';

interface WalletTransactionsCashFlowState {
  isLoading: boolean;
  isError: boolean;
  data: TransactionCashFlowItem[];
  isIncomesIncluded: boolean;
  month: Date;
  currencyCode: string | null;
}

const initialState: WalletTransactionsCashFlowState = {
  isLoading: false,
  isError: false,
  isIncomesIncluded: true,
  data: [],
  month: new Date(),
  currencyCode: null,
};

export const WalletTransactionsCashFlowStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withMethods((store, repository = inject(WalletRepository)) => ({
    async loadCashFlow(): Promise<Result> {
      patchState(store, () => ({
        isLoading: true,
      }));

      try {
        if (!store.currencyCode()) {
          throw new Error('Currency code is not selected');
        }

        const data = await repository.getDailyTransactionCashFlow(
          store.currencyCode()!,
          store.month(),
        );

        patchState(store, () => ({
          isLoading: false,
          data,
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

    updateCurrencyCode(currencyCode: string): void {
      patchState(store, () => ({
        currencyCode,
      }));
    },

    updateMonth(month: Date): void {
      patchState(store, () => ({
        month,
      }));
    },

    toggleIncomes(includeIncomes: boolean): void {
      patchState(store, () => ({
        isIncomesIncluded: includeIncomes,
      }));
    },
  })),
);
