import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
} from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { AccountsStore } from '@core/store/accounts-store';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { DatePickerModule } from 'primeng/datepicker';
import { InputNumberModule } from 'primeng/inputnumber';
import { InputTextModule } from 'primeng/inputtext';
import { SelectModule } from 'primeng/select';
import { SelectButtonModule } from 'primeng/selectbutton';
import { ToastModule } from 'primeng/toast';
import { map } from 'rxjs';
import { TransactionsStore } from '../../store/transactions-store';
import { ExpenseForm, ExpenseFormData } from './ui/expense-form/expense-form';
import { IncomeForm } from './ui/income-form/income-form';

@Component({
  imports: [
    FormsModule,
    CommonModule,
    InputTextModule,
    ButtonModule,
    SelectModule,
    InputNumberModule,
    DatePickerModule,
    SelectButtonModule,
    ExpenseForm,
    IncomeForm,
    ToastModule,
  ],
  templateUrl: './edit-transaction.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [MessageService],
})
export class EditTransaction {
  protected readonly store = inject(TransactionsStore);
  protected readonly accountsStore = inject(AccountsStore);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private messageService = inject(MessageService);

  protected transactionType: 'expense' | 'income' = 'expense';

  protected readonly isCreatingMode = toSignal(
    this.route.data.pipe(map((data) => data['isCreating'])),
  );

  protected readonly title = computed(() =>
    this.isCreatingMode() ? 'New Transaction' : 'Edit Transaction',
  );

  protected readonly transactionTypesOptions = [
    { name: 'Expense', value: 'expense' },
    { name: 'Income', value: 'income' },
  ];

  protected updateGroupInStore($event: number) {
    this.store.updateGroup($event);
  }

  protected async submitExpenseForm($event: ExpenseFormData) {
    if (this.isCreatingMode()) {
      this.createExpenseTransaction($event);
    } else {
      // TODO
      throw new Error('Editing transaction is not implemented yet');
    }
  }

  private async createExpenseTransaction(
    formData: ExpenseFormData,
  ): Promise<void> {
    const { error } = await this.store.createExpenseTransaction(formData);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Transaction creation failed',
        detail: error.message,
      });
      return;
    }

    this.store.markAsNotLoaded();
    await this.router.navigate(['..'], { relativeTo: this.route });
  }
}
