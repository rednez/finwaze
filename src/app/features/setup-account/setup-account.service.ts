import { inject, Injectable, signal } from '@angular/core';
import { CurrenciesRepository } from '@core/repositories/currencies-repository';
import { AccountsStore } from '@core/store/accounts-store';

@Injectable({
  providedIn: 'root',
})
export class SetupAccountService {
  private readonly accountsStore = inject(AccountsStore);
  private readonly currenciesRepository = inject(CurrenciesRepository);

  readonly isLoading = signal(false);
  readonly isCurrenciesLoading = signal(false);
  readonly currencies = signal<Array<{ id: number; name: string }>>([]);

  async loadAccounts(): Promise<boolean> {
    this.isLoading.set(true);

    await this.accountsStore.getAll();

    this.isLoading.set(false);
    return this.accountsStore.hasAccounts();
  }

  async loadCurrencies() {
    this.isCurrenciesLoading.set(true);

    const currencies = await this.currenciesRepository.getAll();
    this.currencies.set(
      currencies.map((i) => ({
        id: i.id,
        name: `${i.code} – ${i.name}`,
      })),
    );

    this.isCurrenciesLoading.set(false);
  }

  async createAccount(name: string, currencyId: number) {
    return this.accountsStore.create(name, currencyId);
  }
}
