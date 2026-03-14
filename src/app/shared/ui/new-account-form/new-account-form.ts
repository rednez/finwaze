import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  output,
} from '@angular/core';
import {
  FormBuilder,
  FormsModule,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { Currency } from '@core/models/currencies';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { SelectModule } from 'primeng/select';

@Component({
  selector: 'app-new-account-form',
  imports: [
    ProgressSpinnerModule,
    InputTextModule,
    FormsModule,
    ReactiveFormsModule,
    ButtonModule,
    SelectModule,
  ],
  templateUrl: './new-account-form.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class NewAccountForm {
  readonly isCurrenciesLoading = input(false);
  readonly currencies = input<Currency[]>([]);
  readonly submit = output<{ accountName: string; currencyId: number }>();

  private readonly formBuilder = inject(FormBuilder);

  protected form = this.formBuilder.group({
    name: [
      null as string | null,
      [Validators.required, Validators.minLength(3), Validators.maxLength(30)],
    ],
    currencyId: [null as string | null, [Validators.required]],
  });

  protected readonly currenciesOptions = computed(() =>
    this.currencies().map((i) => ({
      id: i.id,
      name: `${i.code} – ${i.name}`,
    })),
  );

  onSubmit() {
    this.form.markAllAsDirty();

    if (this.form.valid) {
      this.submit.emit({
        accountName: this.form.controls.name.value!,
        currencyId: Number(this.form.controls.currencyId.value!),
      });
    }
  }
}
