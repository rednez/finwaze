import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  output,
} from '@angular/core';
import { toObservable } from '@angular/core/rxjs-interop';
import {
  FormBuilder,
  FormsModule,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { Currency } from '@core/models/currencies';
import { ButtonModule } from 'primeng/button';
import { DatePickerModule } from 'primeng/datepicker';
import { InputNumberModule } from 'primeng/inputnumber';
import { InputTextModule } from 'primeng/inputtext';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { SelectModule } from 'primeng/select';
import { combineLatest, filter, take, tap } from 'rxjs';

interface SubmitEvent {
  accountName: string;
  currencyId?: number;
  balance?: number;
  balanceDate?: Date | null;
}

@Component({
  selector: 'app-new-account-form',
  imports: [
    ProgressSpinnerModule,
    InputTextModule,
    FormsModule,
    ReactiveFormsModule,
    ButtonModule,
    SelectModule,
    InputNumberModule,
    DatePickerModule,
  ],
  templateUrl: './new-account-form.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class NewAccountForm {
  readonly initialAccountName = input<string>();
  readonly initialCurrencyId = input<number>();
  readonly initialBalance = input<number>();
  readonly isCurrenciesLoading = input(false);
  readonly currencies = input<Currency[]>([]);
  readonly submitBtnLabel = input('Create');
  readonly isCurrencyDisabled = input(false);
  readonly hasBalance = input(false);
  readonly submitForm = output<SubmitEvent>();

  private readonly formBuilder = inject(FormBuilder);

  protected readonly today = new Date();

  protected form = this.formBuilder.group({
    name: [
      null as string | null,
      [Validators.required, Validators.minLength(3), Validators.maxLength(30)],
    ],
    currencyId: [null as number | null, [Validators.required]],
    balance: null as number | null,
    balanceDate: null as Date | null,
  });

  protected readonly currenciesOptions = computed(() =>
    this.currencies().map((i) => ({
      id: i.id,
      name: `${i.code} – ${i.name}`,
    })),
  );

  private readonly currencies$ = toObservable(this.currencies);
  private readonly initialAccountName$ = toObservable(this.initialAccountName);
  private readonly initialCurrencyId$ = toObservable(this.initialCurrencyId);
  private readonly initialBalance$ = toObservable(this.initialBalance);

  constructor() {
    this.initFormValues();
  }

  onSubmit() {
    this.form.markAllAsDirty();

    if (this.form.valid) {
      const submitEvent: SubmitEvent = {
        accountName: this.form.controls.name.value!,
      };

      if (this.hasBalance()) {
        submitEvent.balance = Number(this.form.controls.balance.value);
        submitEvent.balanceDate = this.form.controls.balanceDate.value;
      }
      if (!this.isCurrencyDisabled()) {
        submitEvent.currencyId = Number(this.form.controls.currencyId.value);
      }

      this.submitForm.emit(submitEvent);
    }
  }

  private initFormValues() {
    combineLatest([
      this.currencies$,
      this.initialAccountName$,
      this.initialCurrencyId$,
      this.initialBalance$,
    ])
      .pipe(
        filter(
          ([
            currencies,
            initialAccountName,
            initialCurrencyId,
            initialBalance,
          ]) =>
            currencies.length > 0 &&
            !!initialAccountName &&
            !!initialCurrencyId &&
            (this.hasBalance() ? initialBalance !== undefined : true),
        ),
        tap(([, initialAccountName, initialCurrencyId, initialBalance]) => {
          this.form.patchValue({
            name: initialAccountName,
            currencyId: initialCurrencyId,
            balance: initialBalance,
          });

          if (this.isCurrencyDisabled()) {
            this.form.controls.currencyId.disable();
          }
          if (this.hasBalance()) {
            this.form.controls.balance.addValidators(Validators.required);
          }
        }),
        take(1),
      )
      .subscribe();
  }
}
