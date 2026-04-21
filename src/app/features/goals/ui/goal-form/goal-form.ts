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
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { ButtonModule } from 'primeng/button';
import { DatePickerModule } from 'primeng/datepicker';
import { InputNumberModule } from 'primeng/inputnumber';
import { InputTextModule } from 'primeng/inputtext';
import { SelectModule } from 'primeng/select';
import { combineLatest, filter, take, tap } from 'rxjs';

export interface GoalFormData {
  name: string;
  targetAmount: number;
  targetDate: Date;
  currencyId?: number;
}

@Component({
  selector: 'app-goal-form',
  imports: [
    FormsModule,
    ReactiveFormsModule,
    InputTextModule,
    InputNumberModule,
    DatePickerModule,
    SelectModule,
    ButtonModule,
    TranslatePipe,
  ],
  templateUrl: './goal-form.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GoalForm {
  readonly isEditMode = input(false);
  readonly readonly = input(false);
  readonly initialName = input<string>();
  readonly initialTargetAmount = input<number>();
  readonly initialTargetDate = input<Date>();
  readonly initialCurrencyCode = input<string>();
  readonly currencies = input<Currency[]>([]);
  readonly isCurrenciesLoading = input(false);
  readonly submitBtnLabel = input('Create Goal');
  readonly submitForm = output<GoalFormData>();

  private readonly formBuilder = inject(FormBuilder);

  protected readonly form = this.formBuilder.group({
    name: [
      null as string | null,
      [Validators.required, Validators.minLength(3), Validators.maxLength(30)],
    ],
    targetAmount: [
      null as number | null,
      [Validators.required, Validators.min(1)],
    ],
    targetDate: [null as Date | null, [Validators.required]],
    currencyId: [null as number | null, [Validators.required]],
  });

  protected readonly today = new Date();

  protected readonly currenciesOptions = computed(() =>
    this.currencies().map((c) => ({
      id: c.id,
      name: `${c.code} – ${c.name}`,
    })),
  );

  private readonly initialName$ = toObservable(this.initialName);
  private readonly initialTargetAmount$ = toObservable(
    this.initialTargetAmount,
  );
  private readonly initialTargetDate$ = toObservable(this.initialTargetDate);

  constructor() {
    this.initFormValues();
  }

  onSubmit() {
    this.form.markAllAsDirty();

    if (this.form.valid) {
      const data: GoalFormData = {
        name: this.form.controls.name.value!,
        targetAmount: this.form.controls.targetAmount.value!,
        targetDate: this.form.controls.targetDate.value!,
      };

      if (!this.isEditMode()) {
        data.currencyId = this.form.controls.currencyId.value!;
      }

      this.submitForm.emit(data);
    }
  }

  private initFormValues() {
    combineLatest([
      this.initialName$,
      this.initialTargetAmount$,
      this.initialTargetDate$,
    ])
      .pipe(
        filter(
          ([name, amount, date]) => !!name && amount != null && date != null,
        ),
        tap(([name, amount, date]) => {
          this.form.patchValue({
            name,
            targetAmount: amount,
            targetDate: date,
          });
          if (this.isEditMode()) {
            this.form.controls.currencyId.disable();
          }
          if (this.readonly()) {
            this.form.disable();
          }
        }),
        take(1),
      )
      .subscribe();
  }
}
