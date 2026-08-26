import {
  Component,
  DestroyRef,
  inject,
  input,
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
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { AccountSelect } from '@shared/ui/account-select';
import { AmountField } from '@shared/ui/amount-field';
import { CategoryPicker } from '@shared/ui/category-picker';
import { DateTimeField } from '@shared/ui/date-time-field';
import { InputTextModule } from '@openng/optimus-ui/inputtext';
import { combineLatest, filter, map, shareReplay, take, tap } from 'rxjs';
import { IncomeFormData } from '../../models';
import { FormActionButtons } from '../form-action-buttons';
import { NamePromptDialog } from '../name-prompt-dialog';

@Component({
  selector: 'app-income-form',
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
  templateUrl: './income-form.html',
})
export class IncomeForm {
  readonly isCreatingMode = input(false);
  readonly isSubmitting = input(false);
  readonly initialValues = input<Partial<IncomeFormData>>();
  readonly accounts = input<Account[]>([]);
  readonly groups = input<Group[]>([]);
  readonly categories = input<Category[]>([]);
  readonly accountChanged = output<number>();
  readonly groupChanged = output<number>();
  readonly categoryChanged = output<number | null>();
  readonly formSubmitted = output<IncomeFormData>();
  readonly clickDelete = output();
  readonly clickAddGroup = output<string>();
  readonly clickAddCategory = output<{ name: string; groupId: number }>();

  private readonly formBuilder = inject(FormBuilder);
  private readonly destroyRef = inject(DestroyRef);

  protected readonly form = this.formBuilder.group({
    accountId: [null as number | null, [Validators.required]],
    groupId: [null as number | null, [Validators.required]],
    categoryId: [null as number | null, [Validators.required]],
    amount: [
      null as number | null,
      [Validators.required, Validators.min(0.01)],
    ],
    transactedAt: [new Date(), [Validators.required]],
    comment: [null as string | null, [Validators.maxLength(100)]],
  });

  /** Mirrors `groupId` so the category picker can highlight the current group. */
  protected readonly selectedGroupId = signal<number | null>(null);

  private readonly selectedAccount$ =
    this.form.controls.accountId.valueChanges.pipe(
      map((value) => this.accounts().find((acc) => acc.id === value)),
      shareReplay(1),
    );

  protected readonly selectedCurrencyCode = toSignal(
    this.selectedAccount$.pipe(map((acc) => acc?.currencyCode ?? '')),
    { initialValue: '' },
  );

  protected isNewGroupDialogVisible = false;
  protected isNewCategoryDialogVisible = false;
  protected newCategoryGroupId: number | null = null;

  private readonly accounts$ = toObservable(this.accounts);
  private readonly groups$ = toObservable(this.groups);
  private readonly categories$ = toObservable(this.categories);
  private readonly initialValues$ = toObservable(this.initialValues);

  constructor() {
    this.initFormValues();
  }

  protected submit() {
    this.form.markAllAsDirty();

    if (this.form.valid) {
      this.formSubmitted.emit({
        ...this.form.value,
        currencyCode: this.selectedCurrencyCode(),
      } as IncomeFormData);
    }
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
      this.initialValues$,
    ])
      .pipe(
        filter(
          ([accounts, groups, categories, initialValues]) =>
            accounts.length > 0 &&
            groups.length > 0 &&
            categories.length > 0 &&
            !!initialValues,
        ),
        map((values) => values[3]),
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
  }

  private watchAccountChanges() {
    this.selectedAccount$
      .pipe(filter(Boolean), takeUntilDestroyed(this.destroyRef))
      .subscribe((acc) => this.accountChanged.emit(acc.id));
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
}
