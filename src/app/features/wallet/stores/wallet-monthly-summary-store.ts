import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { resultError, resultOk } from '@core/utils/result-factory';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';
import { MonthlySummary } from '../models';
import { WalletRepository } from '../repositories';

interface WalletMonthlySummaryState {
  isLoading: boolean;
  isError: boolean;
  data: MonthlySummary[];
  month: Date;
  currencyCode: string | null;
}

const initialState: WalletMonthlySummaryState = {
  isLoading: false,
  isError: false,
  data: [],
  month: new Date(),
  currencyCode: null,
};

export const WalletMonthlySummaryStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withMethods((store, repository = inject(WalletRepository)) => ({
    async loadMonthlySummary(): Promise<Result> {
      patchState(store, () => ({
        isLoading: true,
      }));

      try {
        if (!store.currencyCode()) {
          throw new Error('Currency code is not selected');
        }

        const data = await repository.getMonthlySummary(
          store.month(),
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

    updateMonth(month: Date): void {
      patchState(store, () => ({
        month,
      }));
    },
  })),
);
