import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  output,
} from '@angular/core';
import {
  takeUntilDestroyed,
  toObservable,
  toSignal,
} from '@angular/core/rxjs-interop';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Account } from '@core/models/accounts';
import { Category, Group } from '@core/models/categories';
import { SelectDesignTokens } from '@primeuix/themes/types/select';
import { ButtonModule } from 'primeng/button';
import { DatePickerModule } from 'primeng/datepicker';
import { InputNumberModule } from 'primeng/inputnumber';
import { InputTextModule } from 'primeng/inputtext';
import { SelectModule } from 'primeng/select';
import { SelectButtonModule } from 'primeng/selectbutton';
import { filter, map } from 'rxjs';
import { expenseChargedAmountValidator } from '../../../../../transactions/utils';

export interface ExpenseFormData {
  accountId: number;
  groupId: number;
  categoryId: number;
  transactedAt: Date;
  comment: string;
  transactionAmount: number;
  transactionCurrency: string;
  chargedAmount: number;
}

@Component({
  selector: 'app-expense-form',
  imports: [
    ReactiveFormsModule,
    CommonModule,
    InputTextModule,
    ButtonModule,
    SelectModule,
    InputNumberModule,
    DatePickerModule,
    SelectButtonModule,
  ],
  templateUrl: './expense-form.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ExpenseForm {
  readonly isCreatingMode = input(false);
  readonly isSubmitting = input(false);
  readonly initValue = input<ExpenseFormData>();
  readonly accounts = input<Account[]>([]);
  readonly groups = input<Group[]>([]);
  readonly categories = input<Category[]>([]);
  readonly currencies = input<string[]>([]);
  readonly groupChanged = output<number>();
  readonly formSubmitted = output<ExpenseFormData>();

  private readonly formBuilder = inject(FormBuilder);

  protected form = this.formBuilder.group(
    {
      accountId: [this.initValue()?.accountId, [Validators.required]],
      _accountCurrency: [''],
      groupId: [this.initValue()?.groupId, [Validators.required]],
      categoryId: [this.initValue()?.categoryId, [Validators.required]],
      transactionAmount: [
        this.initValue()?.transactionAmount,
        [Validators.required, Validators.min(0.01)],
      ],
      transactionCurrency: [
        this.initValue()?.transactionCurrency,
        [Validators.required],
      ],
      chargedAmount: [this.initValue()?.chargedAmount, [Validators.min(0.01)]],
      transactedAt: [
        this.initValue()?.transactedAt || new Date(),
        [Validators.required],
      ],
      comment: [this.initValue()?.comment, [Validators.maxLength(100)]],
    },
    { validators: [expenseChargedAmountValidator] },
  );

  protected readonly submitButtonLabel = computed(() =>
    this.isCreatingMode() ? 'Create' : 'Save Changes',
  );

  protected readonly selectDt: SelectDesignTokens = {
    root: {
      borderRadius: '16px',
    },
  };

  protected readonly selectedAccount = toSignal(
    this.form.controls.accountId.valueChanges.pipe(
      map((value) => this.accounts().find((acc) => acc.id === value)),
    ),
  );

  protected readonly selectedTransactionCurrency = toSignal(
    this.form.controls.transactionCurrency.valueChanges,
  );

  protected readonly transactionAmount = toSignal(
    this.form.controls.transactionAmount.valueChanges,
  );

  protected readonly chargedAmount = toSignal(
    this.form.controls.chargedAmount.valueChanges,
  );

  protected readonly shouldShowChargedAmount = computed(
    () =>
      this.selectedAccount() &&
      this.selectedAccount()?.currencyCode !==
        this.selectedTransactionCurrency(),
  );

  protected readonly exchangeRate = computed(() =>
    this.transactionAmount() && this.chargedAmount()
      ? (this.chargedAmount() as number) / (this.transactionAmount() as number)
      : null,
  );

  protected readonly currenciesOptions = computed(() => [
    ...this.currencies().map((currency) => ({
      name: currency,
      value: currency,
    })),
  ]);

  constructor() {
    this.watchAccountIdChanges();
    this.watchGroupIdChanges();
    this.watchChargedAmountVisability();
  }

  protected submit() {
    this.form.markAllAsDirty();

    if (this.form.valid) {
      this.formSubmitted.emit({
        ...this.form.value,
        chargedAmount: this.shouldShowChargedAmount()
          ? this.form.value.chargedAmount
          : this.form.value.transactionAmount,
      } as ExpenseFormData);
    }
  }

  private watchAccountIdChanges() {
    toObservable(this.selectedAccount)
      .pipe(filter(Boolean), takeUntilDestroyed())
      .subscribe((acc) => {
        this.form.controls._accountCurrency.setValue(acc.currencyCode);

        if (this.form.controls.transactionCurrency.value !== acc.currencyCode) {
          this.form.controls.transactionCurrency.setValue(acc.currencyCode);
        }
      });
  }

  private watchGroupIdChanges() {
    this.form.controls.groupId.valueChanges
      .pipe(filter(Boolean), takeUntilDestroyed())
      .subscribe((value) => {
        this.form.controls.categoryId.reset();
        this.groupChanged.emit(value);
      });
  }

  private watchChargedAmountVisability() {
    toObservable(this.shouldShowChargedAmount)
      .pipe(
        filter((value) => !value),
        takeUntilDestroyed(),
      )
      .subscribe(() => this.form.controls.chargedAmount.reset());
  }
}
