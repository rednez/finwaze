import {
  ChangeDetectionStrategy,
  Component,
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
import { Account } from '@core/models/accounts';
import { SelectDesignTokens } from '@primeuix/themes/types/select';
import { SelectModule } from 'primeng/select';

@Component({
  selector: 'app-account-select',
  imports: [SelectModule, FormsModule],
  templateUrl: './account-select.html',
  host: { class: 'w-full' },
  changeDetection: ChangeDetectionStrategy.OnPush,
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
  readonly accounts = input<Account[]>([]);
  readonly isInvalid = input(false);

  protected selectedAccount = model<number | null>(null);
  protected isDisabled = signal(false);
  protected readonly selectDt: SelectDesignTokens = {
    root: {
      borderRadius: '16px',
    },
  };

  private onChange?: (value: number) => void;
  private onTouched?: VoidFunction;

  writeValue(accountId: number | null): void {
    // TODO
    console.log(accountId);

    this.selectedAccount.set(accountId);
  }

  registerOnChange(fn: any): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: any): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.isDisabled.set(isDisabled);
  }

  onModelChanges($event: number) {
    this.onChange?.($event);
  }
}
