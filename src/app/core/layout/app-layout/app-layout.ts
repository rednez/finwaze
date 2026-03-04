import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { AccountsStore } from '@core/store/accounts-store';
import { CategoriesStore } from '@core/store/categories-store';
import { BottomNavBar } from '../bottom-nav-bar';
import { Sidebar } from '../sidebar';
import { TopBar } from '../top-bar';
import { CurrenciesStore } from '@core/store/currencies-store';
import { UiStore } from '@core/store/ui-store';

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
  private readonly uiStore = inject(UiStore);
  private readonly accountsStore = inject(AccountsStore);
  private readonly currenciesStore = inject(CurrenciesStore);
  private readonly categoriesStore = inject(CategoriesStore);

  constructor() {
    this.initUiStore();
    this.initAccountsStore();
    this.initCategoriesStore();
    this.initCurrenciesStore();
  }

  private initUiStore() {
    this.uiStore.restoreFromLocalStorage();
  }

  private initAccountsStore() {
    if (!this.accountsStore.selectedCurrencyCode()) {
      this.accountsStore.restoreFromLocalStorage();
    }
    if (!this.accountsStore.isLoaded()) {
      this.accountsStore.getAll();
    }
  }

  private initCategoriesStore() {
    this.categoriesStore.loadAll();
  }

  private initCurrenciesStore() {
    if (!this.currenciesStore.isLoaded()) {
      this.currenciesStore.getAll();
    }
  }
}
