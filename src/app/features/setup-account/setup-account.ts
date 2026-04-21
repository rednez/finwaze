import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { LocalizationService } from '@core/services/localization.service';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { NewAccountForm } from '@shared/ui/new-account-form';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { SelectModule } from 'primeng/select';
import { ToastModule } from 'primeng/toast';
import { SetupAccountService } from './setup-account.service';

@Component({
  imports: [
    ProgressSpinnerModule,
    InputTextModule,
    FormsModule,
    ReactiveFormsModule,
    ButtonModule,
    SelectModule,
    ToastModule,
    NewAccountForm,
    TranslatePipe,
  ],
  templateUrl: './setup-account.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [MessageService],
})
export class SetupAccount {
  private readonly router = inject(Router);
  private readonly service = inject(SetupAccountService);
  private readonly messageService = inject(MessageService);
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  protected readonly isLoading = this.service.isLoading;
  protected readonly isCurrenciesLoading = this.service.isCurrenciesLoading;
  protected readonly currencies = this.service.currencies;

  constructor() {
    this.initialize();
  }

  protected async createAccount({
    accountName,
    currencyId,
  }: {
    accountName: string;
    currencyId: number;
  }) {
    const { error } = await this.service.createAccount(accountName, currencyId);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: this.t('misc.setup.creationFailed'),
        detail: error.message,
      });
    } else {
      this.router.navigate(['dashboard']);
    }
  }

  private async initialize() {
    const hasAccounts = await this.service.loadAccounts();
    if (hasAccounts) {
      this.router.navigate(['dashboard']);
    } else {
      this.service.loadCurrencies();
    }
  }
}
