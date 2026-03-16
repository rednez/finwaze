import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { AccountsStore } from '@core/store/accounts-store';
import { CurrenciesStore } from '@core/store/currencies-store';
import { NewAccountForm } from '@shared/ui/new-account-form';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { MessageModule } from 'primeng/message';
import { ToastModule } from 'primeng/toast';
import { WalletAccountsStore } from '../../stores';
import { FormPageLayout } from '@core/layout/form-page-layout';

@Component({
  imports: [
    ButtonModule,
    ToastModule,
    NewAccountForm,
    MessageModule,
    FormPageLayout,
  ],
  templateUrl: './account-settings.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [MessageService],
})
export class AccountSettings {
  protected readonly currenciesStore = inject(CurrenciesStore);
  protected readonly accountsStore = inject(AccountsStore);
  protected readonly walletAccountsStore = inject(WalletAccountsStore);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);
  private readonly messageService = inject(MessageService);

  protected readonly selectedAccount = this.walletAccountsStore.selectedAccount;

  constructor() {
    this.checkAndLoadAccountData();
  }

  gotoBack() {
    this.walletAccountsStore.updateSelectedAccountId(null);
    this.router.navigate(['..'], { relativeTo: this.route });
  }

  async updateAccount({
    accountName,
    currencyId,
    balance,
  }: {
    accountName: string;
    currencyId?: number;
    balance?: number;
  }) {
    const { error } = await this.walletAccountsStore.updateRegularAccount({
      accountName,
      currencyId,
      balance,
    });

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Account updating failed',
        detail: error.message,
      });
    } else {
      this.gotoBack();
    }
  }

  async deleteAccount() {
    const { error } = await this.walletAccountsStore.deleteRegularAccount(
      this.selectedAccount()!.id,
    );

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Account deleting failed',
        detail: error.message,
      });
    } else {
      this.gotoBack();
    }
  }

  private async checkAndLoadAccountData() {
    if (!this.walletAccountsStore.selectedAccount()) {
      const accId = this.route.snapshot.paramMap.get('id') as string;
      const { error } = await this.walletAccountsStore.loadAccountDetails(
        Number(accId),
      );

      if (!error) {
        this.walletAccountsStore.updateSelectedAccountId(Number(accId));
      }
    }
  }
}
