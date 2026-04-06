import {
  ChangeDetectionStrategy,
  Component,
  effect,
  inject,
  input,
  model,
  output,
  signal,
  untracked,
} from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Account } from '@core/models/accounts';
import { SavingsGoal } from '@core/models/savings-goal';
import { AccountSelect } from '@shared/ui/account-select';
import { ButtonModule } from 'primeng/button';
import { DatePickerModule } from 'primeng/datepicker';
import { DialogModule } from 'primeng/dialog';
import { InputNumberModule } from 'primeng/inputnumber';
import { GoalsRepository } from '../../repositories/goals-repository';

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
  private readonly repository = inject(GoalsRepository);
  private readonly fb = inject(FormBuilder);

  readonly goal = input.required<SavingsGoal>();
  readonly visible = model(false);
  readonly loading = input(false);
  readonly submitted = output<{
    fromAccountId: number;
    amount: number;
    transactedAt?: Date | null;
  }>();

  protected readonly today = new Date();
  protected readonly accounts = signal<Account[]>([]);
  protected readonly isLoadingAccounts = signal(false);

  protected readonly form = this.fb.group({
    fromAccountId: [null as number | null, Validators.required],
    amount: [
      null as number | null,
      [Validators.required, Validators.min(0.01)],
    ],
    transactedAt: [null as Date | null],
  });

  constructor() {
    effect(() => {
      if (this.visible()) {
        untracked(() => this.loadAccounts());
      } else {
        untracked(() => this.form.reset());
      }
    });
  }

  private async loadAccounts(): Promise<void> {
    this.isLoadingAccounts.set(true);
    try {
      const accounts = await this.repository.getRegularAccountsByCurrency(
        this.goal().currencyCode,
      );
      this.accounts.set(accounts);
    } finally {
      this.isLoadingAccounts.set(false);
    }
  }

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
