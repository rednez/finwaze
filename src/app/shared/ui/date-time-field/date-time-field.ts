import { formatDate } from '@angular/common';
import {
  Component,
  computed,
  forwardRef,
  inject,
  input,
  LOCALE_ID,
  model,
  signal,
  viewChild,
} from '@angular/core';
import {
  ControlValueAccessor,
  FormsModule,
  NG_VALUE_ACCESSOR,
} from '@angular/forms';
import { ResponsiveHelper } from '@core/services/responsive-helper';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { ResponsiveOverlay } from '@shared/ui/responsive-overlay';
import { ButtonModule } from '@openng/optimus-ui/button';
import { DatePickerModule } from '@openng/optimus-ui/datepicker';

/** Mirrors the date picker's own `mm/dd/yy` + 24h input text on the mobile trigger. */
const TRIGGER_FORMAT = 'MM/dd/yyyy HH:mm';

/**
 * The stock date picker on desktop; on mobile the calendar moves into a
 * full-screen sheet, because the popup panel is taller than a phone viewport.
 */
@Component({
  selector: 'app-date-time-field',
  imports: [
    DatePickerModule,
    ResponsiveOverlay,
    ButtonModule,
    FormsModule,
    TranslatePipe,
  ],
  templateUrl: './date-time-field.html',
  host: { class: 'block w-full' },
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => DateTimeField),
      multi: true,
    },
  ],
})
export class DateTimeField implements ControlValueAccessor {
  readonly label = input<string>();
  readonly inputId = input.required<string>();
  readonly isInvalid = input(false);

  readonly isMobile = inject(ResponsiveHelper).isMobile;

  private readonly locale = inject(LOCALE_ID);

  protected readonly value = model<Date | null>(null);
  protected readonly isDisabled = signal(false);

  protected readonly displayValue = computed(() => {
    const value = this.value();

    return value ? formatDate(value, TRIGGER_FORMAT, this.locale) : '';
  });

  protected readonly triggerClass = computed(() =>
    this.isInvalid()
      ? 'border-[var(--p-form-field-invalid-border-color)]'
      : 'border-surface hover:border-[var(--p-form-field-hover-border-color)]',
  );

  protected readonly inputStyle = { borderRadius: '16px' };

  private readonly overlay = viewChild(ResponsiveOverlay);

  private onChange?: (value: Date | null) => void;
  private onTouched?: VoidFunction;

  writeValue(value: Date | null): void {
    this.value.set(value);
  }

  registerOnChange(fn: (value: Date | null) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: VoidFunction): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.isDisabled.set(isDisabled);
  }

  protected update(value: Date | null) {
    this.value.set(value);
    this.onChange?.(value);
    this.onTouched?.();
  }

  protected done() {
    this.overlay()?.close();
  }
}
