import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  effect,
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
import { ButtonModule } from 'primeng/button';
import { DatePickerModule } from 'primeng/datepicker';
import { DialogModule } from 'primeng/dialog';
import { InputNumberModule } from 'primeng/inputnumber';

@Component({
  selector: 'app-withdraw-from-goal-dialog',
  imports: [
    CommonModule,
    DialogModule,
    ButtonModule,
    ReactiveFormsModule,
    InputNumberModule,
    DatePickerModule,
    AccountSelect,
    TranslatePipe,
  ],
  templateUrl: './withdraw-from-goal-dialog.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class WithdrawFromGoalDialog {
  readonly goal = input.required<SavingsGoal>();
  readonly accounts = input<Account[]>([]);
  readonly submitted = output<{
    toAccountId: number;
    amount: number;
    transactedAt?: Date | null;
  }>();

  private readonly fb = inject(FormBuilder);

  readonly visible = model(false);

  protected readonly filteredAccounts = computed(() =>
    this.accounts().filter(
      (a) =>
        a.currencyCode === this.goal().currencyCode && a.id !== this.goal().id,
    ),
  );

  protected readonly today = new Date();

  protected readonly form = this.fb.group({
    toAccountId: [null as number | null, Validators.required],
    amount: [
      null as number | null,
      [Validators.required, Validators.min(0.01)],
    ],
    transactedAt: [null as Date | null],
  });

  constructor() {
    effect(() => {
      const max = this.goal().accumulatedAmount;
      this.form.controls.amount.addValidators([Validators.max(max)]);
      this.form.controls.amount.updateValueAndValidity();
    });
  }

  protected submit(): void {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;

    const { toAccountId, amount, transactedAt } = this.form.getRawValue();
    this.submitted.emit({
      toAccountId: toAccountId!,
      amount: amount!,
      transactedAt,
    });
  }

  protected close(): void {
    this.visible.set(false);
  }
}
