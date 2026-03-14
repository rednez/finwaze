import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { resultError, resultOk } from '@core/utils/result-factory';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';
import { RegularAccount } from '../models/regular-account';
import { WalletRepository } from '../repositories';

interface WalletAccountsState {
  isLoading: boolean;
  isUpdating: boolean;
  isLoaded: boolean;
  isError: boolean;
  accounts: RegularAccount[];
}

const initialState: WalletAccountsState = {
  isLoading: false,
  isLoaded: false,
  isUpdating: false,
  isError: false,
  accounts: [],
};

export const WalletAccountsStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withMethods((store, repository = inject(WalletRepository)) => ({
    async loadAccounts(): Promise<Result> {
      if (store.isLoaded()) {
        patchState(store, () => ({
          isUpdating: true,
        }));
      } else {
        patchState(store, () => ({
          isLoading: true,
        }));
      }

      try {
        const data = await repository.getRegularAccounts();

        if (store.isLoaded()) {
          patchState(store, () => ({
            isUpdating: false,
            accounts: data,
          }));
        } else {
          patchState(store, () => ({
            isLoading: false,
            isLoaded: true,
            accounts: data,
          }));
        }

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
