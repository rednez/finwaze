import { computed, inject, Injectable, signal } from '@angular/core';
import { CurrenciesRepository } from '@core/repositories/currencies-repository';
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
  readonly currencies = computed(() =>
    this.currenciesStore.currencies().map((i) => ({
      id: i.id,
      name: `${i.code} – ${i.name}`,
    })),
  );

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
