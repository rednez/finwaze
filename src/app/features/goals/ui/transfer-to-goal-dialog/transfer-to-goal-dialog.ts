import {
  Component,
  computed,
  inject,
  input,
  model,
  output,
} from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Account } from '@core/models/accounts';
import { SavingsGoal } from '@core/models/savings-goal';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { AccountSelect } from '@shared/ui/account-select';
import { ButtonModule } from '@openng/optimus-ui/button';
import { DatePickerModule } from '@openng/optimus-ui/datepicker';
import { DialogModule } from '@openng/optimus-ui/dialog';
import { InputNumberModule } from '@openng/optimus-ui/inputnumber';

@Component({
  selector: 'app-transfer-to-goal-dialog',
  imports: [
    DialogModule,
    ButtonModule,
    ReactiveFormsModule,
    InputNumberModule,
    DatePickerModule,
    AccountSelect,
    TranslatePipe,
  ],
  templateUrl: './transfer-to-goal-dialog.html',
})
export class TransferToGoalDialog {
  readonly goal = input.required<SavingsGoal>();
  readonly accounts = input<Account[]>([]);
  readonly submitted = output<{
    fromAccountId: number;
    amount: number;
    transactedAt?: Date | null;
  }>();

  private readonly fb = inject(FormBuilder);

  readonly visible = model(false);

  protected readonly filteredAccounts = computed(() =>
    this.accounts().filter((a) => a.currencyCode === this.goal().currencyCode),
  );

  protected readonly today = new Date();

  protected readonly form = this.fb.group({
    fromAccountId: [null as number | null, Validators.required],
    amount: [
      null as number | null,
      [Validators.required, Validators.min(0.01)],
    ],
    transactedAt: [null as Date | null],
  });

  protected submit(): void {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;

    const { fromAccountId, amount, transactedAt } = this.form.getRawValue();
    this.submitted.emit({
      fromAccountId: fromAccountId!,
      amount: amount!,
      transactedAt,
    });
  }

  protected close(): void {
    this.visible.set(false);
  }
}
