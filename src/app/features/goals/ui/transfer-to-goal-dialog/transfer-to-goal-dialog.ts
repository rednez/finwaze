import {
  ChangeDetectionStrategy,
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
import { AccountSelect } from '@shared/ui/account-select';
import { ButtonModule } from 'primeng/button';
import { DatePickerModule } from 'primeng/datepicker';
import { DialogModule } from 'primeng/dialog';
import { InputNumberModule } from 'primeng/inputnumber';

@Component({
  selector: 'app-transfer-to-goal-dialog',
  imports: [
    DialogModule,
    ButtonModule,
    ReactiveFormsModule,
    InputNumberModule,
    DatePickerModule,
    AccountSelect,
  ],
  templateUrl: './transfer-to-goal-dialog.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
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
