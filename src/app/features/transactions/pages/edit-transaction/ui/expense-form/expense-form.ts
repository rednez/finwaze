import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  DestroyRef,
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
import { combineLatest, filter, map, shareReplay, take, tap } from 'rxjs';
import { expenseChargedAmountValidator } from '../../../../../transactions/utils';

export interface ExpenseFormData {
  accountId: number;
  groupId: number;
  categoryId: number;
  transactedAt: Date;
  comment: string;
  transactionAmount: number;
  transactionCurrencyCode: string;
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
  readonly initialValues = input<Partial<ExpenseFormData>>();
  readonly accounts = input<Account[]>([]);
  readonly groups = input<Group[]>([]);
  readonly categories = input<Category[]>([]);
  readonly currencies = input<string[]>([]);
  readonly accountChanged = output<number>();
  readonly groupChanged = output<number>();
  readonly categoryChanged = output<number | null>();
  readonly transactionCurrencyCodeChanged = output<string | null>();
  readonly formSubmitted = output<ExpenseFormData>();

  private readonly formBuilder = inject(FormBuilder);
  private readonly destroyRef = inject(DestroyRef);

  protected form = this.formBuilder.group(
    {
      accountId: [null as number | null, [Validators.required]],
      _accountCurrency: [''],
      groupId: [null as number | null, [Validators.required]],
      categoryId: [null as number | null, [Validators.required]],
      transactionAmount: [
        null as number | null,
        [Validators.required, Validators.min(0.01)],
      ],
      transactionCurrencyCode: [null as string | null, [Validators.required]],
      chargedAmount: [null as number | null, [Validators.min(0.01)]],
      transactedAt: [new Date(), [Validators.required]],
      comment: [null as string | null, [Validators.maxLength(100)]],
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

  protected readonly filteredCategories = computed(() => {
    return this.categories().filter(
      (c) => c.groupId === this.selectedGroupId(),
    );
  });

  private readonly selectedAccount$ =
    this.form.controls.accountId.valueChanges.pipe(
      map((value) => this.accounts().find((acc) => acc.id === value)),
      shareReplay(1),
    );

  protected readonly selectedAccountCurrencyCode$ = this.selectedAccount$.pipe(
    map((acc) => (!!acc ? acc.currencyCode : '')),
  );

  protected readonly shouldShowChargedAmount$ = combineLatest([
    this.selectedAccount$,
    this.form.controls.transactionCurrencyCode.valueChanges,
  ]).pipe(
    map(
      ([selectedAccount, transactionCurrency]) =>
        !!selectedAccount &&
        selectedAccount.currencyCode !== transactionCurrency,
    ),
    shareReplay(1),
  );

  protected readonly exchangeRate = toSignal(
    combineLatest([
      this.form.controls.transactionAmount.valueChanges,
      this.form.controls.chargedAmount.valueChanges,
    ]).pipe(
      map(([transactionAmount, chargedAmount]) =>
        !!transactionAmount && !!chargedAmount
          ? chargedAmount / transactionAmount
          : null,
      ),
    ),
  );

  protected readonly currenciesOptions = computed(() => [
    ...this.currencies().map((currency) => ({
      name: currency,
      value: currency,
    })),
  ]);

  private readonly accounts$ = toObservable(this.accounts);
  private readonly groups$ = toObservable(this.groups);
  private readonly categories$ = toObservable(this.categories);
  private readonly currencies$ = toObservable(this.currencies);
  private readonly initialValues$ = toObservable(this.initialValues);
  private readonly shouldShowChargedAmount = toSignal(
    this.shouldShowChargedAmount$,
    { initialValue: false },
  );
  private readonly selectedGroupId = toSignal(
    this.form.controls.groupId.valueChanges,
  );

  constructor() {
    this.initFormValues();
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

  private initFormValues() {
    combineLatest([
      this.accounts$,
      this.groups$,
      this.categories$,
      this.currencies$,
      this.initialValues$,
    ])
      .pipe(
        filter(
          ([accounts, groups, categories, currencies, initialValues]) =>
            accounts.length > 0 &&
            groups.length > 0 &&
            categories.length > 0 &&
            currencies.length > 0 &&
            !!initialValues,
        ),
        map((values) => values[4]),
        tap((initialValues) => {
          this.startWatchFormChanges();
          this.form.patchValue(initialValues!);
        }),
        take(1),
      )
      .subscribe();
  }

  private startWatchFormChanges() {
    this.watchAccountChanges();
    this.watchGroupIdChanges();
    this.watchCategoryIdChanges();
    this.watchTransactionCurrencyCodeChanges();
    this.watchChargedAmountVisability();
  }

  private watchAccountChanges() {
    this.selectedAccount$
      .pipe(filter(Boolean), takeUntilDestroyed(this.destroyRef))
      .subscribe((acc) => {
        this.accountChanged.emit(acc.id);
        this.form.controls._accountCurrency.setValue(acc.currencyCode);

        if (
          this.form.controls.transactionCurrencyCode.value !== acc.currencyCode
        ) {
          this.form.controls.transactionCurrencyCode.setValue(acc.currencyCode);
        }
      });
  }

  private watchGroupIdChanges() {
    this.form.controls.groupId.valueChanges
      .pipe(filter(Boolean), takeUntilDestroyed(this.destroyRef))
      .subscribe((value) => {
        this.groupChanged.emit(value);
        this.form.controls.categoryId.reset();
        this.groupChanged.emit(value);
        this.categoryChanged.emit(null);
      });
  }

  private watchCategoryIdChanges() {
    this.form.controls.categoryId.valueChanges
      .pipe(filter(Boolean), takeUntilDestroyed(this.destroyRef))
      .subscribe((value) => {
        this.groupChanged.emit(this.form.controls.groupId.value!);
        this.categoryChanged.emit(value);
      });
  }

  private watchTransactionCurrencyCodeChanges() {
    this.form.controls.transactionCurrencyCode.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe((code) => {
        this.transactionCurrencyCodeChanged.emit(code);
      });
  }

  private watchChargedAmountVisability() {
    this.shouldShowChargedAmount$
      .pipe(filter(Boolean), takeUntilDestroyed(this.destroyRef))
      .subscribe(() => {
        this.form.controls.chargedAmount.reset();
      });
  }
}
