import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { AccountsStore } from '@core/store/accounts-store';
import { CurrenciesStore } from '@core/store/currencies-store';
import { NewAccountForm } from '@shared/ui/new-account-form';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { ToastModule } from 'primeng/toast';

@Component({
  imports: [ButtonModule, ToastModule, NewAccountForm],
  templateUrl: './new-account.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [MessageService],
})
export class NewAccount {
  protected readonly currenciesStore = inject(CurrenciesStore);
  protected readonly accountsStore = inject(AccountsStore);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);
  private readonly messageService = inject(MessageService);

  gotoBack() {
    this.router.navigate(['..'], { relativeTo: this.route });
  }

  async createAccount({
    accountName,
    currencyId,
  }: {
    accountName: string;
    currencyId: number;
  }) {
    const { error } = await this.accountsStore.create(accountName, currencyId);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Account creation failed',
        detail: error.message,
      });
    } else {
      this.gotoBack();
    }
  }
}
