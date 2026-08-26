import {
  Component,
  computed,
  forwardRef,
  inject,
  input,
  model,
  signal,
  viewChild,
} from '@angular/core';
import {
  ControlValueAccessor,
  FormsModule,
  NG_VALUE_ACCESSOR,
} from '@angular/forms';
import { Account } from '@core/models/accounts';
import { ResponsiveHelper } from '@core/services/responsive-helper';
import { SelectDesignTokens } from '@openng/optimus-ui-themes/types/select';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { ResponsiveOverlay } from '@shared/ui/responsive-overlay';
import { SelectModule } from '@openng/optimus-ui/select';
import { CurrencyCodeChip } from '../currency-code-chip';

/** The transfer page renders two of these side by side, so the label/control
 *  pairing needs an id that is unique per instance. */
let nextUniqueId = 0;

@Component({
  selector: 'app-account-select',
  imports: [
    SelectModule,
    FormsModule,
    CurrencyCodeChip,
    ResponsiveOverlay,
    TranslatePipe,
  ],
  templateUrl: './account-select.html',
  host: { class: 'w-full block' },
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => AccountSelect),
      multi: true,
    },
  ],
})
export class AccountSelect implements ControlValueAccessor {
  readonly label = input<string>();
  readonly placeholder = input<string>();
  readonly accounts = input<Account[]>([]);
  readonly isInvalid = input(false);

  readonly isMobile = inject(ResponsiveHelper).isMobile;

  protected readonly fieldId = `account-select-${nextUniqueId++}`;

  protected selectedAccount = model<number | null>(null);
  protected isDisabled = signal(false);
  protected readonly selectDt: SelectDesignTokens = {
    root: {
      borderRadius: '16px',
    },
  };

  protected readonly selectedOption = computed(() =>
    this.accounts().find((account) => account.id === this.selectedAccount()),
  );

  protected readonly triggerClass = computed(() =>
    this.isInvalid()
      ? 'border-[var(--p-form-field-invalid-border-color)]'
      : 'border-surface hover:border-[var(--p-form-field-hover-border-color)]',
  );

  private readonly overlay = viewChild(ResponsiveOverlay);

  private onChange?: (value: number) => void;
  private onTouched?: VoidFunction;

  writeValue(accountId: number | null): void {
    this.selectedAccount.set(accountId);
  }

  registerOnChange(fn: (value: number) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: VoidFunction): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.isDisabled.set(isDisabled);
  }

  onModelChanges($event: number) {
    this.onChange?.($event);
  }

  protected select(accountId: number) {
    this.selectedAccount.set(accountId);
    this.onChange?.(accountId);
    this.onTouched?.();
    this.overlay()?.close();
  }
}
