import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
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
import { DialogModule } from 'primeng/dialog';

@Component({
  selector: 'app-complete-goal-dialog',
  imports: [
    CommonModule,
    DialogModule,
    ButtonModule,
    ReactiveFormsModule,
    AccountSelect,
  ],
  templateUrl: './complete-goal-dialog.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CompleteGoalDialog {
  readonly goal = input.required<SavingsGoal>();
  readonly accounts = input<Account[]>([]);
  readonly visible = model(false);
  readonly confirmed = output<{ toAccountId: number }>();

  private readonly fb = inject(FormBuilder);

  protected readonly form = this.fb.group({
    toAccountId: [null as number | null, Validators.required],
  });

  protected confirm(): void {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    this.confirmed.emit({ toAccountId: this.form.getRawValue().toAccountId! });
  }

  protected close(): void {
    this.visible.set(false);
  }
}
