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
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { AccountSelect } from '@shared/ui/account-select';
import { Select } from '@shared/ui/select';
import { DatePickerModule } from 'primeng/datepicker';
import { InputNumberModule } from 'primeng/inputnumber';
import { InputTextModule } from 'primeng/inputtext';
import { SelectButtonModule } from 'primeng/selectbutton';
import { combineLatest, filter, map, shareReplay, take, tap } from 'rxjs';
import { IncomeFormData } from '../../models';
import { FormActionButtons } from '../form-action-buttons';
import { NamePromptDialog } from '../name-prompt-dialog';

@Component({
  selector: 'app-income-form',
  imports: [
    ReactiveFormsModule,
    CommonModule,
    InputTextModule,
    InputNumberModule,
    DatePickerModule,
    SelectButtonModule,
    FormActionButtons,
    AccountSelect,
    Select,
    NamePromptDialog,
    TranslatePipe,
  ],
  templateUrl: './income-form.html',
  styles: ``,
  changeDetection: ChangeDetectionStrategy.OnPush,
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

  protected readonly selectedCurrencyCode = toSignal(
    this.selectedAccount$.pipe(map((acc) => (acc ? acc.currencyCode : ''))),
    { initialValue: '' },
  );

  protected isNewGroupDialogVisible = false;
  protected isNewCategoryDialogVisible = false;
  private readonly accounts$ = toObservable(this.accounts);
  private readonly groups$ = toObservable(this.groups);
  private readonly categories$ = toObservable(this.categories);
  private readonly initialValues$ = toObservable(this.initialValues);
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
        currencyCode: this.selectedCurrencyCode(),
      } as IncomeFormData);
    }
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
        }),
        take(1),
      )
      .subscribe();
  }

  private startWatchFormChanges() {
    this.watchAccountChanges();
    this.watchGroupIdChanges();
    this.watchCategoryIdChanges();
  }

  private watchAccountChanges() {
    this.selectedAccount$
      .pipe(filter(Boolean), takeUntilDestroyed(this.destroyRef))
      .subscribe((acc) => this.accountChanged.emit(acc.id));
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
}
