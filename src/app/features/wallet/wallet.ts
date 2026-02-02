import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  signal,
} from '@angular/core';
import { AppStore } from '@store/app-store';
import { RecentTransactionsWidget } from '@ui/recent-transactions-widget';
import { AccountCard } from './ui/account-card/account-card';
import { TransactionsOverviewWidget } from './ui/transactions-overview-widget/transactions-overview-widget';

@Component({
  imports: [AccountCard, TransactionsOverviewWidget, RecentTransactionsWidget],
  template: `
    <div class="flex flex-wrap gap-4">
      @for (acc of accounts(); track acc.name) {
        <app-account-card
          [name]="acc.name"
          [balance]="acc.balance"
          [currency]="acc.currency"
        />
      }
    </div>

    <app-transactions-overview-widget
      class="grow sm:flex-1 min-w-0 sm:min-w-75 max-w-152 lg:max-w-full"
    />

    <app-recent-transactions-widget [transactions]="recentTransactions()" />
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    class: 'flex flex-col gap-4',
  },
})
export class Wallet {
  private readonly store = inject(AppStore);

  protected readonly accounts = signal([
    {
      name: 'Заначка в конверті в сейфі',
      balance: 12300.3,
      currency: 'USD',
    },
    {
      name: 'Карта Mono',
      balance: 542300.99,
      currency: 'UAH',
    },
    {
      name: 'Заначка в конверті',
      balance: 1200,
      currency: 'EUR',
    },
  ]);

  protected readonly recentTransactions = computed(() =>
    this.store.transactions().slice(0, 3),
  );
}
