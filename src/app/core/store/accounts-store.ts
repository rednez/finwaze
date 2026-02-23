import { computed, inject } from '@angular/core';
import { Account } from '@core/models/accounts';
import { AccountsRepository } from '@core/repositories/accounts-repository';
import { AccountsLocalStorage } from '@core/services/accounts-local-storage';
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
  selectedAccountId: number | undefined;
  selectedCurrencyCode: string | undefined;
  accounts: Account[];
}

const initialState: AccountsState = {
  isLoading: false,
  isLoaded: false,
  isError: false,
  isCreating: false,
  selectedAccountId: undefined,
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
        } catch (error) {
          patchState(store, () => ({
            isLoading: false,
            isError: true,
          }));
        }
      },

      async create(name: string, currencyId: number): Promise<boolean> {
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

          return true;
        } catch (error) {
          patchState(store, (state) => ({
            isCreating: false,
          }));

          return false;
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
    }),
  ),
);
