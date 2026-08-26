import { formatNumber } from '@angular/common';
import {
  Component,
  computed,
  DestroyRef,
  inject,
  input,
  LOCALE_ID,
  output,
  signal,
} from '@angular/core';
import {
  takeUntilDestroyed,
  toObservable,
  toSignal,
} from '@angular/core/rxjs-interop';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Account } from '@core/models/accounts';
import { Category, Group } from '@core/models/categories';
import { InputTextModule } from '@openng/optimus-ui/inputtext';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { AccountSelect } from '@shared/ui/account-select';
import { AmountField } from '@shared/ui/amount-field';
import { CategoryPicker } from '@shared/ui/category-picker';
import { DateTimeField } from '@shared/ui/date-time-field';
import { combineLatest, filter, map, shareReplay, take, tap } from 'rxjs';
import { ExpenseFormData } from '../../models';
import { expenseChargedAmountValidator } from '../../utils';
import { FormActionButtons } from '../form-action-buttons';
import { NamePromptDialog } from '../name-prompt-dialog';

@Component({
  selector: 'app-expense-form',
  imports: [
    ReactiveFormsModule,
    InputTextModule,
    FormActionButtons,
    AccountSelect,
    AmountField,
    CategoryPicker,
    DateTimeField,
    NamePromptDialog,
    TranslatePipe,
  ],
  templateUrl: './expense-form.html',
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
  readonly clickDelete = output();
  readonly clickAddGroup = output<string>();
  readonly clickAddCategory = output<{ name: string; groupId: number }>();

  private readonly formBuilder = inject(FormBuilder);
  private readonly destroyRef = inject(DestroyRef);
  private readonly locale = inject(LOCALE_ID);

  protected readonly form = this.formBuilder.group(
    {
      accountId: [null as number | null, [Validators.required]],
      _accountCurrencyCode: [''],
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

  /** Mirrors `groupId` so the category picker can highlight the current group. */
  protected readonly selectedGroupId = signal<number | null>(null);

  private readonly selectedAccount$ =
    this.form.controls.accountId.valueChanges.pipe(
      map((value) => this.accounts().find((acc) => acc.id === value)),
      shareReplay(1),
    );

  private readonly shouldShowChargedAmount$ = combineLatest([
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

  protected readonly shouldShowChargedAmount = toSignal(
    this.shouldShowChargedAmount$,
    { initialValue: false },
  );

  protected readonly accountCurrencyCode = toSignal(
    this.selectedAccount$.pipe(map((acc) => acc?.currencyCode ?? '')),
    { initialValue: '' },
  );

  protected readonly transactionCurrencyCode = toSignal(
    this.form.controls.transactionCurrencyCode.valueChanges,
    { initialValue: null },
  );

  private readonly exchangeRate = toSignal(
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

  protected readonly exchangeRateHint = computed(() => {
    const rate = this.exchangeRate();
    const from = this.transactionCurrencyCode();
    const to = this.accountCurrencyCode();

    if (!rate || !from || !to) {
      return '';
    }

    return `1 ${from} = ${formatNumber(rate, this.locale, '1.2-4')} ${to}`;
  });

  protected isNewGroupDialogVisible = false;
  protected isNewCategoryDialogVisible = false;
  protected newCategoryGroupId: number | null = null;

  private readonly accounts$ = toObservable(this.accounts);
  private readonly groups$ = toObservable(this.groups);
  private readonly categories$ = toObservable(this.categories);
  private readonly currencies$ = toObservable(this.currencies);
  private readonly initialValues$ = toObservable(this.initialValues);

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

  protected onTransactionCurrencyChange(code: string | null) {
    this.form.controls.transactionCurrencyCode.setValue(code);
    this.form.controls.transactionCurrencyCode.markAsDirty();
  }

  protected onGroupIdChange(groupId: number | null) {
    this.selectedGroupId.set(groupId);
    this.form.controls.groupId.setValue(groupId);
  }

  protected onAddCategoryClick(groupId: number) {
    this.newCategoryGroupId = groupId;
    this.isNewCategoryDialogVisible = true;
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
          this.selectedGroupId.set(initialValues?.groupId ?? null);
        }),
        take(1),
      )
      .subscribe();
  }

  private startWatchFormChanges() {
    this.watchAccountChanges();
    this.watchCategoryIdChanges();
    this.watchTransactionCurrencyCodeChanges();
    this.watchChargedAmountVisability();
  }

  private watchAccountChanges() {
    this.selectedAccount$
      .pipe(filter(Boolean), takeUntilDestroyed(this.destroyRef))
      .subscribe((acc) => {
        this.accountChanged.emit(acc.id);
        this.form.controls._accountCurrencyCode.setValue(acc.currencyCode);

        if (
          this.form.controls.transactionCurrencyCode.value !== acc.currencyCode
        ) {
          this.form.controls.transactionCurrencyCode.setValue(acc.currencyCode);
        }
      });
  }

  private watchCategoryIdChanges() {
    this.form.controls.categoryId.valueChanges
      .pipe(filter(Boolean), takeUntilDestroyed(this.destroyRef))
      .subscribe((value) => {
        const groupId = this.form.controls.groupId.value;

        if (groupId) {
          this.groupChanged.emit(groupId);
        }

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
