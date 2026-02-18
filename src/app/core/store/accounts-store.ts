import { computed, inject } from '@angular/core';
import { Account } from '@core/models/accounts';
import { AccountsRepository } from '@core/repositories/accounts-repository';
import {
  patchState,
  signalStore,
  withMethods,
  withState,
  withComputed,
} from '@ngrx/signals';

export interface AccountsState {
  isLoading: boolean;
  isError: boolean;
  selectedAccountId: number | undefined;
  accounts: Account[];
}

const initialState: AccountsState = {
  isLoading: false,
  isError: false,
  selectedAccountId: undefined,
  accounts: [],
};

export const AccountsStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withComputed((store) => ({
    hasAccounts: () => store.accounts().length > 0,
    firstAccount: () => store.accounts()[0],

    myCurrencies: computed(() => {
      const currencies = store
        .accounts()
        .map((account) => account.currencyCode);
      return Array.from(new Set(currencies));
    }),
  })),

  withMethods((store, repository = inject(AccountsRepository)) => ({
    async getAll(): Promise<void> {
      patchState(store, () => ({
        isLoading: true,
      }));

      try {
        const data = await repository.getAll();

        patchState(store, () => ({
          isLoading: false,
          isError: false,
          accounts: data,
        }));
      } catch (error) {
        patchState(store, () => ({
          isLoading: false,
          isError: true,
        }));
      }
    },
  })),
);
