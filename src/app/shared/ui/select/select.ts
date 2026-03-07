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
  readonly options = input<any[]>([]);
  readonly isInvalid = input(false);
  readonly hasAddButton = input(false);

  protected selectedOption = model<number | null>(null);
  protected isDisabled = signal(false);
  protected readonly selectDt: SelectDesignTokens = {
    root: {
      borderRadius: '16px',
    },
  };

  private onChange?: (value: any) => void;
  private onTouched?: VoidFunction;

  writeValue(accountId: number | null): void {
    this.selectedOption.set(accountId);
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

  onModelChanges($event: any) {
    this.onChange?.($event);
  }
}
