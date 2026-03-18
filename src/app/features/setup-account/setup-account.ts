import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { Router } from '@angular/router';
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
  ],
  templateUrl: './setup-account.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [MessageService],
})
export class SetupAccount {
  private readonly router = inject(Router);
  private readonly service = inject(SetupAccountService);
  private messageService = inject(MessageService);

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
        summary: 'Failed to create account',
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
