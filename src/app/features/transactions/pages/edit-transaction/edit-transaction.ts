import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  OnDestroy,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { AccountsStore } from '@core/store/accounts-store';
import { UiStore } from '@core/store/ui-store';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { DatePickerModule } from 'primeng/datepicker';
import { InputNumberModule } from 'primeng/inputnumber';
import { InputTextModule } from 'primeng/inputtext';
import { SelectModule } from 'primeng/select';
import { SelectButtonModule } from 'primeng/selectbutton';
import { ToastModule } from 'primeng/toast';
import { ExpenseTransactionStore } from '../../store/expense-transaction-store';
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
export class EditTransaction implements OnDestroy {
  protected readonly transactionsStore = inject(TransactionsStore);
  protected readonly expenseTransactionStore = inject(ExpenseTransactionStore);
  protected readonly uiStore = inject(UiStore);
  protected readonly accountsStore = inject(AccountsStore);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly messageService = inject(MessageService);

  protected transactionType: 'expense' | 'income' = 'expense';

  protected readonly title = computed(() =>
    this.expenseTransactionStore.isCreatingMode()
      ? 'New Transaction'
      : 'Edit Transaction',
  );

  protected readonly transactionTypesOptions = [
    { name: 'Expense', value: 'expense' },
    { name: 'Income', value: 'income' },
  ];

  constructor() {
    this.defineMode();
  }

  ngOnDestroy(): void {
    this.expenseTransactionStore.reset();
  }

  protected gotoBack() {
    this.router.navigate(['..'], { relativeTo: this.route });
  }

  protected onAccountChanged($event: number) {
    this.uiStore.updateExpenseTransactionForm({ accountId: $event });
  }

  protected onGroupChanged($event: number) {
    this.uiStore.updateExpenseTransactionForm({ groupId: $event });
  }

  protected onCategoryChanged($event: number | null) {
    this.uiStore.updateExpenseTransactionForm({ categoryId: $event });
  }

  onTransactionCurrencyCodeChanged($event: string | null) {
    this.uiStore.updateExpenseTransactionForm({
      transactionCurrencyCode: $event,
    });
  }

  protected async submitExpenseForm($event: ExpenseFormData) {
    if (this.expenseTransactionStore.isCreatingMode()) {
      this.createExpenseTransaction($event);
    } else {
      this.updateExpenseTransaction($event);
    }
  }

  private defineMode() {
    this.expenseTransactionStore.updateIsCreatingMode(
      this.route.snapshot.url[0].path === 'create',
    );
  }

  private async createExpenseTransaction(
    formData: ExpenseFormData,
  ): Promise<void> {
    const { error } =
      await this.expenseTransactionStore.createTransaction(formData);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Transaction creation failed',
        detail: error.message,
      });
    } else {
      this.transactionsStore.markAsNotLoaded();
      await this.router.navigate(['..'], { relativeTo: this.route });
    }
  }

  private async updateExpenseTransaction(
    formData: ExpenseFormData,
  ): Promise<void> {
    const { error } =
      await this.expenseTransactionStore.updateTransaction(formData);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Transaction update failed',
        detail: error.message,
      });
    } else {
      this.transactionsStore.markAsNotLoaded();
      this.messageService.add({
        severity: 'success',
        summary: 'Transaction updated successfully',
      });
    }
  }
}
