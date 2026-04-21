import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { FormPageLayout } from '@core/layout/form-page-layout';
import { LocalizationService } from '@core/services/localization.service';
import { AccountsStore } from '@core/store/accounts-store';
import { CurrenciesStore } from '@core/store/currencies-store';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { NewAccountForm } from '@shared/ui/new-account-form';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { ToastModule } from 'primeng/toast';

@Component({
  imports: [
    ButtonModule,
    ToastModule,
    NewAccountForm,
    FormPageLayout,
    TranslatePipe,
  ],
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
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

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
        summary: this.t('wallet.newAccount.creationFailed'),
        detail: error.message,
      });
    } else {
      this.gotoBack();
    }
  }
}
