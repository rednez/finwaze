import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { resultError, resultOk } from '@core/utils/result-factory';
import { patchState, signalStore, withMethods, withState } from '@ngrx/signals';
import { RegularAccount } from '../models/regular-account';
import { WalletRepository } from '../repositories';

export interface WalletState {
  isLoadingAccounts: boolean;
  isErrorAccounts: boolean;
  accounts: RegularAccount[];
}

const initialState: WalletState = {
  isLoadingAccounts: false,
  isErrorAccounts: false,
  accounts: [],
};

export const WalletStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withMethods((store, repository = inject(WalletRepository)) => ({
    async loadAccounts(): Promise<Result> {
      patchState(store, () => ({
        isLoadingAccounts: true,
      }));

      try {
        const data = await repository.getRegularAccounts();

        patchState(store, () => ({
          isLoadingAccounts: false,
          accounts: data,
        }));

        return resultOk();
      } catch (error: any) {
        patchState(store, () => ({
          ...initialState,
          isErrorAccounts: true,
        }));

        return resultError(error);
      }
    },
  })),
);
