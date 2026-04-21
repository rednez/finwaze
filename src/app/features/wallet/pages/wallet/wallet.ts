import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { AccountsStore } from '@core/store/accounts-store';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import dayjs from 'dayjs';
import { ButtonModule } from 'primeng/button';
import {
  WalletAccountsStore,
  WalletMonthlySummaryStore,
  WalletRecentTransactionsStore,
  WalletTransactionsCashFlowStore,
} from '../../stores';
import {
  AccountCard,
  StatisticsWidget,
  TransactionsOverviewWidget,
  WalletRecentTransactionsCard,
} from '../../ui';

@Component({
  imports: [
    AccountCard,
    TransactionsOverviewWidget,
    StatisticsWidget,
    WalletRecentTransactionsCard,
    ButtonModule,
    TranslatePipe,
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
  protected readonly walletMonthlySummaryStore = inject(
    WalletMonthlySummaryStore,
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
      !dayjs($event).isSame(
        this.walletTransactionsCashFlowStore.month(),
        'month',
      )
    ) {
      this.walletTransactionsCashFlowStore.updateMonth($event);
      this.walletTransactionsCashFlowStore.loadCashFlow();
    }
  }

  onRecentTransactionsCurrencyChanged($event: string) {
    if (this.walletRecentTransactionsStore.currencyCode() !== $event) {
      this.walletRecentTransactionsStore.updateCurrencyCode($event);
      this.walletRecentTransactionsStore.loadTransactions();
    }
  }

  onMonthlySummaryCurrencyChanged($event: string) {
    if (this.walletMonthlySummaryStore.currencyCode() !== $event) {
      this.walletMonthlySummaryStore.updateCurrencyCode($event);
      this.walletMonthlySummaryStore.loadMonthlySummary();
    }
  }

  onMonthlySummaryMonthChanged($event: Date) {
    if (
      !dayjs($event).isSame(this.walletMonthlySummaryStore.month(), 'month')
    ) {
      this.walletMonthlySummaryStore.updateMonth($event);
      this.walletMonthlySummaryStore.loadMonthlySummary();
    }
  }

  gotoTransactions() {
    this.router.navigate(['transactions']);
  }

  gotoNewAccount() {
    this.router.navigate(['wallet', 'create']);
  }

  gotoAccountSettings(accountId: number) {
    this.walletAccountsStore.updateSelectedAccountId(accountId);
    this.router.navigate(['wallet', accountId]);
  }

  gotoTransfer() {
    this.router.navigate(['wallet', 'transfer']);
  }

  private loadData() {
    this.walletAccountsStore.loadAccounts();
    this.loadTransactionsCashFlow();
    this.loadRecentTransactions();
    this.loadMonthlySummary();
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

  private loadMonthlySummary() {
    if (this.walletMonthlySummaryStore.currencyCode()) {
      this.walletMonthlySummaryStore.loadMonthlySummary();
    } else {
      if (this.accountsStore.selectedCurrencyCode()) {
        this.walletMonthlySummaryStore.updateCurrencyCode(
          this.accountsStore.selectedCurrencyCode()!,
        );
        this.walletMonthlySummaryStore.loadMonthlySummary();
      }
    }
  }
}
