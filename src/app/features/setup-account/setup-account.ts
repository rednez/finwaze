import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import {
  FormBuilder,
  FormsModule,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { Router } from '@angular/router';
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
  ],
  templateUrl: './setup-account.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [MessageService],
})
export class SetupAccount {
  private readonly router = inject(Router);
  private readonly service = inject(SetupAccountService);
  private readonly formBuilder = inject(FormBuilder);
  private messageService = inject(MessageService);

  protected readonly isLoading = this.service.isLoading;
  protected readonly isCurrenciesLoading = this.service.isCurrenciesLoading;
  protected readonly currencies = this.service.currencies;

  protected form = this.formBuilder.group({
    name: [
      '',
      [Validators.required, Validators.minLength(3), Validators.maxLength(30)],
    ],
    currency: ['', [Validators.required]],
  });

  constructor() {
    this.initialize();
  }

  protected async createAccount() {
    this.form.markAllAsDirty();

    if (this.form.valid) {
      const isCreated = await this.service.createAccount(
        this.form.controls.name.value!,
        Number(this.form.controls.currency.value!),
      );

      if (isCreated) {
        this.router.navigate(['dashboard']);
      } else {
        this.messageService.add({
          severity: 'error',
          summary: 'Failed to create account',
          detail: 'An error occurred while creating the account.',
        });
      }
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
