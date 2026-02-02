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
import { StatisticsWidget } from './ui/statistics-widget/statistics-widget';
import { TransactionsOverviewWidget } from './ui/transactions-overview-widget/transactions-overview-widget';

@Component({
  imports: [
    AccountCard,
    TransactionsOverviewWidget,
    RecentTransactionsWidget,
    StatisticsWidget,
  ],
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

    <div class="grid lg:grid-flow-col lg:grid-rows-2 gap-4">
      <app-transactions-overview-widget class="lg:col-span-2 min-w-0" />

      <app-recent-transactions-widget
        class="lg:col-span-2"
        [transactions]="recentTransactions()"
      />

      <app-statistics-widget
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
