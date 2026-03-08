import {
  ChangeDetectionStrategy,
  Component,
  computed,
  model,
  output,
} from '@angular/core';
import {
  FormControl,
  FormsModule,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { TransactionType } from '@core/models/transactions';
import { ButtonModule } from 'primeng/button';
import { DialogModule } from 'primeng/dialog';
import { InputTextModule } from 'primeng/inputtext';
import { SelectButtonModule } from 'primeng/selectbutton';

@Component({
  selector: 'app-new-group-dialog',
  imports: [
    DialogModule,
    ButtonModule,
    InputTextModule,
    ReactiveFormsModule,
    SelectButtonModule,
    FormsModule,
  ],
  template: `
    <p-dialog
      header="Create new group"
      [modal]="true"
      [(visible)]="visible"
      [style]="{ width: '25rem' }"
    >
      <div class="flex flex-col text-start mb-6">
        <p-selectbutton
          [(ngModel)]="transactionType"
          [options]="transactionTypeOptions"
          optionLabel="label"
          optionValue="value"
          class="mb-4"
          size="small"
          aria-labelledby="basic"
        />

        <label class="text-sm font-medium mb-1" for="name"> Name </label>
        <input
          pInputText
          [formControl]="name"
          id="name"
          class="flex-auto"
          autocomplete="off"
          [dt]="{
            root: {
              borderRadius: '16px',
            },
          }"
        />
        @if (name.invalid && name.dirty) {
          <div class="text-xs text-red-500 pl-2 pt-0.5">
            @if (name.hasError('required')) {
              Name required
            } @else if (name.hasError('maxlength')) {
              {{ maxLengthErrorMessage() }}
            }
          </div>
        }
      </div>

      <p-button label="Create" rounded (onClick)="onCreateClick()" />
    </p-dialog>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class NewGroupDialog {
  readonly createGroup = output<{
    name: string;
    transactionType: TransactionType;
  }>();

  readonly visible = model(false);
  protected readonly transactionType = model('expense');

  protected readonly transactionTypeOptions = [
    { value: 'expense', label: 'Expense' },
    { value: 'income', label: 'Income' },
  ];

  protected readonly name = new FormControl('', [
    Validators.required,
    Validators.maxLength(25),
  ]);

  protected readonly maxLengthErrorMessage = computed(
    () => `Maximum length is 25 characters`,
  );

  protected async onCreateClick() {
    this.name.markAsDirty();

    if (this.name.valid) {
      this.createGroup.emit({
        name: this.name.value!,
        transactionType: this.transactionType() as TransactionType,
      });
      this.name.reset();
      this.visible.set(false);
    }
  }
}
