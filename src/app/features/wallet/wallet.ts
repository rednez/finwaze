import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
} from '@angular/core';
import { Router } from '@angular/router';
import { AccountsStore } from '@core/store/accounts-store';
import { RecentTransactionsWidget } from '@shared/ui/recent-transactions-widget';
import {
  WalletAccountsStore,
  WalletRecentTransactionsStore,
  WalletTransactionsCashFlowStore,
} from './stores';
import { AccountCard } from './ui/account-card';
import { StatisticsWidget } from './ui/statistics-widget';
import { TransactionsOverviewWidget } from './ui/transactions-overview-widget';
import { WalletRecentTransactionsCard } from './ui/wallet-recent-transactions-card/wallet-recent-transactions-card';

@Component({
  imports: [
    AccountCard,
    TransactionsOverviewWidget,
    RecentTransactionsWidget,
    StatisticsWidget,
    WalletRecentTransactionsCard,
  ],
  templateUrl: './wallet.html',
  styles: `
    @reference "tailwindcss";
    :host {
      @apply flex flex-col gap-4;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Wallet {
  protected readonly accountsStore = inject(AccountsStore);
  protected readonly walletAccountsStore = inject(WalletAccountsStore);
  protected readonly walletTransactionsCashFlowStore = inject(
    WalletTransactionsCashFlowStore,
  );
  protected readonly walletRecentTransactionsStore = inject(
    WalletRecentTransactionsStore,
  );
  private readonly router = inject(Router);

  constructor() {
    this.loadData();
  }

  onTransactionsCashFlowIncomesToggled($event: boolean) {
    this.walletTransactionsCashFlowStore.toggleIncomes($event);
  }

  onTransactionsCashFlowCurrencyChanged($event: string) {
    if (this.walletTransactionsCashFlowStore.currencyCode() !== $event) {
      this.walletTransactionsCashFlowStore.updateCurrencyCode($event);
      this.walletTransactionsCashFlowStore.loadCashFlow();
    }
  }

  onTransactionsCashFlowMonthChanged($event: Date) {
    if (
      this.walletTransactionsCashFlowStore.month().getMonth() !==
      $event.getMonth()
    ) {
      this.walletTransactionsCashFlowStore.updateMonth($event);
      this.walletTransactionsCashFlowStore.loadCashFlow();
    }
  }

  onRecentTransactionsChanged($event: string) {
    if (this.walletRecentTransactionsStore.currencyCode() !== $event) {
      this.walletRecentTransactionsStore.updateCurrencyCode($event);
      this.walletRecentTransactionsStore.loadTransactions();
    }
  }

  gotoTransactions() {
    this.router.navigate(['transactions']);
  }

  private loadData() {
    this.walletAccountsStore.loadAccounts();
    this.loadTransactionsCashFlow();
    this.loadRecentTransactions();
  }

  private loadTransactionsCashFlow() {
    if (this.walletTransactionsCashFlowStore.currencyCode()) {
      this.walletTransactionsCashFlowStore.loadCashFlow();
    } else {
      if (this.accountsStore.selectedCurrencyCode()) {
        this.walletTransactionsCashFlowStore.updateCurrencyCode(
          this.accountsStore.selectedCurrencyCode()!,
        );
        this.walletTransactionsCashFlowStore.loadCashFlow();
      }
    }
  }

  private loadRecentTransactions() {
    if (this.walletRecentTransactionsStore.currencyCode()) {
      this.walletRecentTransactionsStore.loadTransactions();
    } else {
      if (this.accountsStore.selectedCurrencyCode()) {
        this.walletRecentTransactionsStore.updateCurrencyCode(
          this.accountsStore.selectedCurrencyCode()!,
        );
        this.walletRecentTransactionsStore.loadTransactions();
      }
    }
  }
}
