import {
  ChangeDetectionStrategy,
  Component,
  computed,
  DestroyRef,
  inject,
  signal,
} from '@angular/core';
import { takeUntilDestroyed, toSignal } from '@angular/core/rxjs-interop';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { FormPageLayout } from '@core/layout/form-page-layout';
import { AccountsStore } from '@core/store/accounts-store';
import { AccountSelect } from '@shared/ui/account-select';
import { ExchangeRateChip } from '@shared/ui/exchange-rate-chip';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { InputNumberModule } from 'primeng/inputnumber';
import { InputTextModule } from 'primeng/inputtext';
import { SelectModule } from 'primeng/select';
import { ToastModule } from 'primeng/toast';
import { combineLatest, distinctUntilChanged, map } from 'rxjs';
import { WalletRepository } from '../../repositories';
import { TransferDirectionPic } from '../../ui/transfer-direction-pic';

@Component({
  imports: [
    InputTextModule,
    ReactiveFormsModule,
    ButtonModule,
    SelectModule,
    InputNumberModule,
    FormPageLayout,
    TransferDirectionPic,
    AccountSelect,
    ExchangeRateChip,
    ToastModule,
  ],
  templateUrl: './transfer.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [MessageService],
})
export class Transfer {
  protected readonly accountsStore = inject(AccountsStore);
  private readonly formBuilder = inject(FormBuilder);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);
  private readonly destroyRef = inject(DestroyRef);
  private readonly repository = inject(WalletRepository);
  private readonly messageService = inject(MessageService);

  protected form = this.formBuilder.group({
    fromAccountId: [null as number | null, [Validators.required]],
    fromAmount: [
      null as number | null,
      [Validators.required, Validators.min(0.01)],
    ],
    toAccountId: [null as number | null, [Validators.required]],
    toAmount: [null as number | null],
  });

  protected readonly shouldShowToAmount = signal(false);

  protected readonly toAccounts = computed(() =>
    this.fromAccountId()
      ? this.accountsStore
          .accounts()
          .filter((a) => a.id !== this.fromAccountId())
      : [],
  );

  protected readonly exchangeRate = computed(() =>
    !!this.fromAmount() && !!this.toAmount() && this.shouldShowToAmount()
      ? this.toAmount()! / this.fromAmount()!
      : null,
  );

  private readonly fromCurrencyCode = signal('');
  private readonly toCurrencyCode = signal('');
  private readonly fromAccountId = toSignal(
    this.form.controls.fromAccountId.valueChanges,
  );
  private readonly fromAmount = toSignal(
    this.form.controls.fromAmount.valueChanges,
  );
  private readonly toAmount = toSignal(
    this.form.controls.toAmount.valueChanges,
  );

  constructor() {
    this.watchFromAccountIdChanges();
    this.watchCurrencyChanges();
  }

  gotoBack() {
    this.router.navigate(['..'], { relativeTo: this.route });
  }

  async submit() {
    this.form.markAllAsDirty();

    if (this.form.valid) {
      try {
        await this.repository.makeTransfer({
          fromAccountId: this.form.value.fromAccountId!,
          toAccountId: this.form.value.toAccountId!,
          fromAmount: this.form.value.fromAmount!,
          toAmount: this.form.value.toAmount!,
        });

        this.gotoBack();
      } catch (error: any) {
        this.messageService.add({
          severity: 'error',
          summary: 'Account creation failed',
          detail: error.message,
        });
      }
    }
  }

  private watchFromAccountIdChanges() {
    this.form.controls.fromAccountId.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => this.form.controls.toAccountId.reset());
  }

  private watchCurrencyChanges() {
    combineLatest([
      this.form.controls.fromAccountId.valueChanges.pipe(
        distinctUntilChanged(),
        map(
          (accId) =>
            this.accountsStore.accounts().find((a) => a.id === accId)
              ?.currencyCode,
        ),
      ),
      this.form.controls.toAccountId.valueChanges.pipe(
        distinctUntilChanged(),
        map(
          (accId) =>
            this.accountsStore.accounts().find((a) => a.id === accId)
              ?.currencyCode,
        ),
      ),
    ])
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(([fromCurrency, toCurrency]) => {
        this.fromCurrencyCode.set(fromCurrency || '');
        this.toCurrencyCode.set(toCurrency || '');
        this.shouldShowToAmount.set(
          !!fromCurrency && !!toCurrency && fromCurrency !== toCurrency,
        );

        if (fromCurrency === toCurrency) {
          this.form.controls.toAmount.removeValidators([
            Validators.required,
            Validators.min(0.01),
          ]);
          this.form.controls.toAmount.reset();
        } else {
          this.form.controls.toAmount.setValidators([
            Validators.required,
            Validators.min(0.01),
          ]);
        }
      });
  }
}
