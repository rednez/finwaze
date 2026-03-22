import {
  ChangeDetectionStrategy,
  Component,
  forwardRef,
  input,
  model,
  output,
  signal,
} from '@angular/core';
import {
  ControlValueAccessor,
  FormsModule,
  NG_VALUE_ACCESSOR,
} from '@angular/forms';
import { SelectDesignTokens } from '@primeuix/themes/types/select';
import { ButtonModule } from 'primeng/button';
import { SelectModule } from 'primeng/select';

@Component({
  selector: 'app-select',
  imports: [SelectModule, FormsModule, ButtonModule],
  templateUrl: './select.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => Select),
      multi: true,
    },
  ],
})
export class Select implements ControlValueAccessor {
  readonly label = input<string>();
  readonly inputId = input.required<string>();
  readonly optionLabel = input('name');
  readonly optionValue = input('value');
  readonly placeholder = input('Select item');
  readonly options = input<unknown[]>([]);
  readonly isInvalid = input(false);
  readonly hasAddButton = input(false);
  readonly clickAddNew = output();

  protected selectedOption = model<number | null>(null);
  protected isDisabled = signal(false);
  protected readonly selectDt: SelectDesignTokens = {
    root: {
      borderRadius: '16px',
    },
  };

  private onChange?: (value: unknown) => void;
  private onTouched?: VoidFunction;

  writeValue(accountId: number | null): void {
    this.selectedOption.set(accountId);
  }

  registerOnChange(fn: (value: unknown) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: VoidFunction): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.isDisabled.set(isDisabled);
  }

  onModelChanges($event: unknown) {
    this.onChange?.($event);
  }
}
