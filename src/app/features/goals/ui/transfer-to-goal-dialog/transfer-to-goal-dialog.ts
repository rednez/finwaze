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
  readonly submitted = output<{ fromAccountId: number; amount: number }>();

  protected readonly accounts = signal<Account[]>([]);
  protected readonly isLoadingAccounts = signal(false);

  protected readonly form = this.fb.group({
    fromAccountId: [null as number | null, Validators.required],
    amount: [
      null as number | null,
      [Validators.required, Validators.min(0.01)],
    ],
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

    const { fromAccountId, amount } = this.form.getRawValue();
    this.submitted.emit({ fromAccountId: fromAccountId!, amount: amount! });
  }

  protected close(): void {
    this.visible.set(false);
  }
}
