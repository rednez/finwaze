import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { AccountsStore } from '@core/store/accounts-store';
import { CurrenciesStore } from '@core/store/currencies-store';
import { BottomNavBar } from '../bottom-nav-bar';
import { Sidebar } from '../sidebar';
import { TopBar } from '../top-bar';

@Component({
  imports: [RouterOutlet, Sidebar, TopBar, BottomNavBar],
  template: `
    <app-sidebar />

    <app-bottom-nav-bar />

    <div class="grow min-w-0">
      <app-top-bar />

      <div class="px-4 pb-24 sm:pb-4">
        <router-outlet />
      </div>
    </div>
  `,
  host: {
    class: 'flex',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AppLayout {
  private readonly accountsStore = inject(AccountsStore);
  private readonly currenciesStore = inject(CurrenciesStore);

  constructor() {
    this.fetchData();
  }

  private async fetchData() {
    await Promise.all([
      this.accountsStore.getAll(),
      this.currenciesStore.getAll(),
    ]);

    if (this.accountsStore.hasAccounts()) {
      this.currenciesStore.updateSelectedCode(
        this.accountsStore.firstAccount().currencyCode,
      );
    }
  }
}
