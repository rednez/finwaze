import { computed, inject, Injectable, signal } from '@angular/core';
import { AccountsStore } from '@core/store/accounts-store';
import { CurrenciesStore } from '@core/store/currencies-store';

@Injectable({
  providedIn: 'root',
})
export class SetupAccountService {
  private readonly accountsStore = inject(AccountsStore);
  private readonly currenciesStore = inject(CurrenciesStore);

  readonly isLoading = signal(false);
  readonly isCurrenciesLoading = this.currenciesStore.isLoading;
  readonly currencies = this.currenciesStore.currencies;

  async loadAccounts(): Promise<boolean> {
    this.isLoading.set(true);

    await this.accountsStore.getAll();

    this.isLoading.set(false);
    return this.accountsStore.hasAccounts();
  }

  async loadCurrencies() {
    this.currenciesStore.getAll();
  }

  async createAccount(name: string, currencyId: number) {
    return this.accountsStore.create(name, currencyId);
  }
}
