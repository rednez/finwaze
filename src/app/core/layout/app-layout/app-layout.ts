import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { BottomNavBar } from '../bottom-nav-bar';
import { Sidebar } from '../sidebar';
import { TopBar } from '../top-bar';
import { AccountsStore } from '@core/store/accounts-store';

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

  constructor() {
    this.initAccountsStore();
  }

  private initAccountsStore() {
    if (!this.accountsStore.selectedCurrencyCode()) {
      this.accountsStore.restoreFromLocalStorage();
    }
    if (!this.accountsStore.isLoaded()) {
      this.accountsStore.getAll();
    }
  }
}
