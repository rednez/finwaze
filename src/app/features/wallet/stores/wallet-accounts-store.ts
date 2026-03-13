import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { resultError, resultOk } from '@core/utils/result-factory';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';
import { RegularAccount } from '../models/regular-account';
import { WalletRepository } from '../repositories';

interface WalletAccountsState {
  isLoading: boolean;
  isError: boolean;
  accounts: RegularAccount[];
}

const initialState: WalletAccountsState = {
  isLoading: false,
  isError: false,
  accounts: [],
};

export const WalletAccountsStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withMethods((store, repository = inject(WalletRepository)) => ({
    async loadAccounts(): Promise<Result> {
      patchState(store, () => ({
        isLoading: true,
      }));

      try {
        const data = await repository.getRegularAccounts();

        patchState(store, () => ({
          isLoading: false,
          accounts: data,
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
  })),
);
