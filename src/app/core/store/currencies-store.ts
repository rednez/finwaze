import { inject } from '@angular/core';
import { Currency } from '@core/models/currencies';
import { CurrenciesRepository } from '@core/repositories/currencies-repository';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';

export interface CurrenciesState {
  isLoading: boolean;
  isError: boolean;
  currencies: Currency[];
  selectedCode: string | undefined;
}

const initialState: CurrenciesState = {
  isLoading: false,
  isError: false,
  currencies: [],
  selectedCode: undefined,
};

export const CurrenciesStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withMethods((store, repository = inject(CurrenciesRepository)) => ({
    async getAll(): Promise<void> {
      patchState(store, () => ({
        isLoading: true,
      }));

      try {
        const data = await repository.getAll();

        patchState(store, () => ({
          isLoading: false,
          isError: false,
          currencies: data,
        }));
      } catch (error) {
        patchState(store, () => ({
          isLoading: false,
          isError: true,
        }));
      }
    },

    updateSelectedCode(code: string): void {
      patchState(store, () => ({
        selectedCode: code,
      }));
    },
  })),
);
