import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
} from '@angular/core';
import { RecentTransactionsWidget } from '@shared/ui/recent-transactions-widget';
import { WalletStore } from './stores';
import { AccountCard } from './ui/account-card';
import { StatisticsWidget } from './ui/statistics-widget';
import { TransactionsOverviewWidget } from './ui/transactions-overview-widget';

@Component({
  imports: [
    AccountCard,
    TransactionsOverviewWidget,
    RecentTransactionsWidget,
    StatisticsWidget,
  ],
  template: `
    <div class="flex flex-wrap gap-4">
      @if (store.isLoadingAccounts()) {
        <app-account-card [isLoading]="true" />
      } @else {
        @for (acc of store.accounts(); track acc.id) {
          <app-account-card
            [name]="acc.name"
            [balance]="acc.balance"
            [currency]="acc.currencyCode"
          />
        }
      }
    </div>

    <div class="grid lg:grid-flow-col lg:grid-rows-2 gap-4">
      <app-transactions-overview-widget class="lg:col-span-2 min-w-0" />

      <app-recent-transactions-widget
        class="lg:col-span-2"
        [transactions]="recentTransactions()"
      />

      <app-wallet-statistics-widget
        class="lg:row-span-2 sm:w-fit sm:min-w-85 xl:min-w-100 2xl:min-w-120"
      />
    </div>
  `,
  styles: `
    @reference "tailwindcss";
    :host {
      @apply flex flex-col gap-4;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Wallet {
  protected readonly store = inject(WalletStore);

  // TODO: ???
  protected readonly recentTransactions = computed(() =>
    // this.store.transactions().slice(0, 3),
    [],
  );

  constructor() {
    this.loadData();
  }

  private loadData() {
    this.store.loadAccounts();
  }
}
