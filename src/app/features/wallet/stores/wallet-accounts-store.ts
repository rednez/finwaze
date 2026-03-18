import { inject } from '@angular/core';
import { Result } from '@core/models/result';
import { AccountsStore } from '@core/store/accounts-store';
import { CurrenciesStore } from '@core/store/currencies-store';
import { resultError, resultOk } from '@core/utils/result-factory';
import {
  patchState,
  signalStore,
  withComputed,
  withMethods,
  withState,
} from '@ngrx/signals';
import { RegularAccount } from '../models/regular-account';
import { WalletRepository } from '../repositories';

interface WalletAccountsState {
  isLoading: boolean;
  isUpdating: boolean;
  isLoaded: boolean;
  isError: boolean;
  isDeleting: boolean;
  accounts: RegularAccount[];
  selectedAccountId: number | null;
}

const initialState: WalletAccountsState = {
  isLoading: false,
  isLoaded: false,
  isUpdating: false,
  isError: false,
  isDeleting: false,
  accounts: [],
  selectedAccountId: null,
};

export const WalletAccountsStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),

  withComputed((store) => ({
    selectedAccount: () =>
      store.accounts().find((i) => i.id === store.selectedAccountId()),
  })),

  withMethods(
    (
      store,
      repository = inject(WalletRepository),
      accountsStore = inject(AccountsStore),
      currenciesStore = inject(CurrenciesStore),
    ) => ({
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

      async loadAccountDetails(id: number): Promise<Result> {
        patchState(store, () => ({
          isLoading: true,
        }));

        try {
          const data = await repository.getRegularAccountDetails(id);

          patchState(store, () => ({
            isLoading: false,
            accounts: [data],
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

      async deleteRegularAccount(accountId: number): Promise<Result> {
        patchState(store, () => ({
          isDeleting: true,
        }));

        try {
          await repository.deleteRegularAccount(accountId);

          patchState(store, (state) => ({
            isDeleting: false,
            accounts: state.accounts.filter((i) => i.id !== accountId),
          }));
          accountsStore.removeAccount(accountId);

          return resultOk();
        } catch (error: any) {
          patchState(store, () => ({
            ...initialState,
            isError: true,
          }));

          return resultError(error);
        }
      },

      async updateRegularAccount({
        accountName,
        currencyId,
        balance,
      }: {
        accountName: string;
        currencyId?: number;
        balance?: number;
      }): Promise<Result> {
        patchState(store, () => ({
          isUpdating: true,
        }));

        try {
          if (!store.selectedAccountId() || !store.selectedAccount()) {
            throw new Error('No account selected');
          }

          await repository.updateRegularAccount({
            accountId: store.selectedAccountId()!,
            accountName,
            currencyId,
          });

          if (
            balance !== undefined &&
            balance !== store.selectedAccount()!.balance
          ) {
            await repository.adjustRegularAccountBalance(
              store.selectedAccountId()!,
              balance,
            );
          }

          const accounts = [...store.accounts()];
          const accountIndex = accounts.findIndex(
            (i) => i.id === store.selectedAccountId(),
          );

          if (accountIndex !== -1) {
            const updatedCurrency =
              currencyId !== undefined
                ? {
                    id: currencyId,
                    code: currenciesStore
                      .currencies()
                      .find((i) => i.id === currencyId)!.code,
                  }
                : accounts[accountIndex].currency;

            const updatedBalance =
              balance !== undefined ? balance : accounts[accountIndex].balance;

            accounts[accountIndex] = {
              ...accounts[accountIndex],
              name: accountName,
              currency: updatedCurrency,
              balance: updatedBalance,
            };

            patchState(store, () => ({
              isUpdating: false,
              accounts,
            }));

            accountsStore.patchAccountInStore({
              id: store.selectedAccountId()!,
              accountName,
              currencyCode: updatedCurrency.code,
            });
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

      updateSelectedAccountId(accountId: number | null) {
        patchState(store, () => ({
          selectedAccountId: accountId,
        }));
      },
    }),
  ),
);
