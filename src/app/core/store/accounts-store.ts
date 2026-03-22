import { computed, inject } from '@angular/core';
import { Account } from '@core/models/accounts';
import { Result } from '@core/models/result';
import { AccountsRepository } from '@core/repositories/accounts-repository';
import { AccountsLocalStorage } from '@core/services/local-storage/accounts-local-storage';
import { resultError, resultOk } from '@core/utils/result-factory';
import {
  patchState,
  signalStore,
  withComputed,
  withMethods,
  withState,
} from '@ngrx/signals';

export interface AccountsState {
  isLoading: boolean;
  isLoaded: boolean;
  isError: boolean;
  isCreating: boolean;
  selectedCurrencyCode: string | undefined;
  accounts: Account[];
}

const initialState: AccountsState = {
  isLoading: false,
  isLoaded: false,
  isError: false,
  isCreating: false,
  selectedCurrencyCode: undefined,
  accounts: [],
};

export const AccountsStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withComputed((store) => ({
    hasAccounts: () => store.accounts().length > 0,

    myCurrencies: computed(() => {
      const currencies = store
        .accounts()
        .map((account) => account.currencyCode);
      return Array.from(new Set(currencies));
    }),
  })),

  withMethods(
    (
      store,
      repository = inject(AccountsRepository),
      accountsLocalStorage = inject(AccountsLocalStorage),
    ) => ({
      async getAll(): Promise<void> {
        patchState(store, () => ({
          isLoading: true,
        }));

        try {
          const data = await repository.getAll();

          if (data.length > 0) {
            accountsLocalStorage.markAccountsAsPresent();

            if (!accountsLocalStorage.selectedCurrencyCode) {
              accountsLocalStorage.setSelectedCurrencyCode(
                data[0].currencyCode,
              );
            }
          } else {
            accountsLocalStorage.clear();
          }

          patchState(store, () => ({
            isLoading: false,
            isLoaded: true,
            isError: false,
            accounts: data,
            selectedCurrencyCode:
              accountsLocalStorage.selectedCurrencyCode || undefined,
          }));
        } catch {
          patchState(store, () => ({
            isLoading: false,
            isError: true,
          }));
        }
      },

      async create(name: string, currencyId: number): Promise<Result> {
        patchState(store, () => ({
          isCreating: true,
        }));

        try {
          const data = await repository.create(name, currencyId);

          accountsLocalStorage.markAccountsAsPresent();
          if (!accountsLocalStorage.selectedCurrencyCode) {
            accountsLocalStorage.setSelectedCurrencyCode(data.currencyCode);
          }

          patchState(store, (state) => ({
            isCreating: false,
            selectedCurrencyCode: accountsLocalStorage.selectedCurrencyCode!,
            accounts: [...state.accounts, data],
          }));

          return resultOk();
        } catch (error) {
          patchState(store, () => ({
            isCreating: false,
          }));

          return resultError(error);
        }
      },

      updateSelectedCurrencyCode(code: string) {
        patchState(store, () => ({
          selectedCurrencyCode: code,
        }));
        accountsLocalStorage.setSelectedCurrencyCode(code);
      },

      restoreFromLocalStorage() {
        const selectedCurrencyCode = accountsLocalStorage.selectedCurrencyCode;

        if (selectedCurrencyCode) {
          patchState(store, () => ({
            selectedCurrencyCode,
          }));
        }
      },

      removeAccount(accountId: number) {
        patchState(store, (state) => ({
          accounts: state.accounts.filter((i) => i.id !== accountId),
        }));
      },

      // TODO
      patchAccountInStore(updatedAccount: {
        id: number;
        accountName: string;
        currencyCode: string;
      }) {
        const accountIndex = store
          .accounts()
          .findIndex((i) => i.id === updatedAccount.id);

        if (accountIndex !== -1) {
          const accounts = [...store.accounts()];
          accounts[accountIndex] = {
            ...accounts[accountIndex],
            name: updatedAccount.accountName,
            currencyCode: updatedAccount.currencyCode,
          };

          patchState(store, () => ({ accounts }));
        }
      },
    }),
  ),
);
