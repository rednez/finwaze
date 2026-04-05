import { inject } from '@angular/core';
import { Currency } from '@core/models/currencies';
import { CurrenciesRepository } from '@core/repositories/currencies-repository';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';

export interface CurrenciesState {
  isLoading: boolean;
  isLoaded: boolean;
  isError: boolean;
  currencies: Currency[];
}

const initialState: CurrenciesState = {
  isLoading: false,
  isLoaded: false,
  isError: false,
  currencies: [],
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
          isLoaded: true,
          currencies: data,
        }));
      } catch {
        patchState(store, () => ({
          isLoading: false,
          isError: true,
        }));
      }
    },

    findByCode(code: string): Currency | undefined {
      return store.currencies().find((c) => c.code === code);
    },
  })),
);
