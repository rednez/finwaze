import {
  Component,
  computed,
  forwardRef,
  input,
  model,
  signal,
} from '@angular/core';
import {
  ControlValueAccessor,
  FormsModule,
  NG_VALUE_ACCESSOR,
} from '@angular/forms';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { CurrencyPicker } from '@shared/ui/currency-picker';
import { InputNumberModule } from '@openng/optimus-ui/inputnumber';

/**
 * A money field that carries its own currency: the amount and the currency
 * selector live inside a single control shell. When `currencies` holds a single
 * code (or none) the currency is rendered as a static badge instead of a picker.
 */
@Component({
  selector: 'app-amount-field',
  imports: [InputNumberModule, FormsModule, CurrencyPicker, TranslatePipe],
  templateUrl: './amount-field.html',
  host: { class: 'block w-full' },
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => AmountField),
      multi: true,
    },
  ],
})
export class AmountField implements ControlValueAccessor {
  readonly label = input<string>();
  readonly inputId = input.required<string>();
  readonly currencies = input<string[]>([]);
  readonly placeholder = input<string>();
  readonly hint = input<string>();
  readonly isInvalid = input(false);
  readonly currencyCode = model<string | null>(null);

  protected readonly amount = model<number | null>(null);
  protected readonly isDisabled = signal(false);

  protected readonly isPickable = computed(() => this.currencies().length > 1);

  protected readonly shellClass = computed(() =>
    this.isInvalid()
      ? 'border-[var(--p-form-field-invalid-border-color)]'
      : 'border-surface focus-within:border-[var(--p-primary-color)]',
  );

  /** The shell draws the border and the focus ring, so the input itself is bare.
   *  Typography is left untouched to match every other control in a form. */
  protected readonly inputStyle = {
    width: '100%',
    border: 'none',
    background: 'transparent',
    boxShadow: 'none',
    paddingLeft: '0',
    paddingRight: '0',
  };

  private onChange?: (value: number | null) => void;
  private onTouched?: VoidFunction;

  writeValue(amount: number | null): void {
    this.amount.set(amount);
  }

  registerOnChange(fn: (value: number | null) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: VoidFunction): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.isDisabled.set(isDisabled);
  }

  protected onAmountChange(amount: number | null) {
    this.onChange?.(amount);
  }

  protected onBlur() {
    this.onTouched?.();
  }
}
