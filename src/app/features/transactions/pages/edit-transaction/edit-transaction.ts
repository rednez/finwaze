import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { FormPageLayout } from '@core/layout/form-page-layout';
import { TransactionType } from '@core/models/transactions';
import { LocalizationService } from '@core/services/localization.service';
import { AccountsStore } from '@core/store/accounts-store';
import { CategoriesStore } from '@core/store/categories-store';
import { UiStore } from '@core/store/ui-store';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { DatePickerModule } from 'primeng/datepicker';
import { InputNumberModule } from 'primeng/inputnumber';
import { InputTextModule } from 'primeng/inputtext';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { SelectModule } from 'primeng/select';
import { SelectButtonModule } from 'primeng/selectbutton';
import { ToastModule } from 'primeng/toast';
import { ExpenseFormData, IncomeFormData } from '../../models';
import {
  ExpenseTransactionStore,
  IncomeTransactionStore,
  SelectedTransactionStore,
  TransactionsStore,
} from '../../store';
import { ExpenseForm } from '../../ui/expense-form';
import { IncomeForm } from '../../ui/income-form';

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
    ProgressSpinnerModule,
    FormPageLayout,
  ],
  // LocalizationService is injected for toast messages only
  templateUrl: './edit-transaction.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [MessageService],
})
export class EditTransaction {
  protected readonly transactionsStore = inject(TransactionsStore);
  protected readonly selectedTransactionStore = inject(
    SelectedTransactionStore,
  );
  protected readonly expenseTransactionStore = inject(ExpenseTransactionStore);
  protected readonly incomeTransactionStore = inject(IncomeTransactionStore);
  protected readonly uiStore = inject(UiStore);
  protected readonly accountsStore = inject(AccountsStore);
  protected readonly categoriesStore = inject(CategoriesStore);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly messageService = inject(MessageService);
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  protected readonly transactionType = signal<'expense' | 'income'>('expense');
  protected isNewExpenseGroupDialogVisible = false;
  protected isNewExpenseCategoryDialogVisible = false;
  protected isNewIncomeGroupDialogVisible = false;
  protected isNewIncomeCategoryDialogVisible = false;

  protected readonly title = computed(() =>
    this.selectedTransactionStore.isCreatingMode()
      ? this.t('transactions.newTransaction')
      : 'Edit Transaction',
  );

  protected readonly shouldShowForms = computed(
    () =>
      this.selectedTransactionStore.isCreatingMode() ||
      !!this.selectedTransactionStore.transaction(),
  );

  protected readonly shouldShowExpenseForm = computed(
    () =>
      (this.selectedTransactionStore.isCreatingMode() &&
        this.transactionType() === 'expense') ||
      (!this.selectedTransactionStore.isCreatingMode() &&
        this.selectedTransactionStore.isExpense()),
  );

  protected readonly shouldShowIncomeForm = computed(
    () =>
      (this.selectedTransactionStore.isCreatingMode() &&
        this.transactionType() === 'income') ||
      (!this.selectedTransactionStore.isCreatingMode() &&
        this.selectedTransactionStore.isIncome()),
  );

  protected readonly transactionTypesOptions = computed(() => [
    { name: this.t('shared.expense'), value: 'expense' },
    { name: this.t('shared.income'), value: 'income' },
  ]);

  constructor() {
    this.defineMode();

    if (this.selectedTransactionStore.shouldLoad()) {
      this.selectedTransactionStore.loadTransaction(
        Number(this.route.snapshot.paramMap.get('id')),
      );
    }
  }

  protected gotoBack() {
    this.router.navigate(['..'], { relativeTo: this.route });
  }

  protected onExpenseAccountChanged($event: number) {
    this.uiStore.updateExpenseTransactionForm({ accountId: $event });
  }

  protected onExpenseGroupChanged($event: number) {
    this.uiStore.updateExpenseTransactionForm({ groupId: $event });
  }

  protected onExpenseCategoryChanged($event: number | null) {
    this.uiStore.updateExpenseTransactionForm({ categoryId: $event });
  }

  protected onTransactionCurrencyCodeChanged($event: string | null) {
    this.uiStore.updateExpenseTransactionForm({
      transactionCurrencyCode: $event,
    });
  }

  protected onIncomeAccountChanged($event: number) {
    this.uiStore.updateIncomeTransactionForm({ accountId: $event });
  }

  protected onIncomeGroupChanged($event: number) {
    this.uiStore.updateIncomeTransactionForm({ groupId: $event });
  }

  protected onIncomeCategoryChanged($event: number | null) {
    this.uiStore.updateIncomeTransactionForm({ categoryId: $event });
  }

  protected async submitExpenseForm($event: ExpenseFormData) {
    if (this.selectedTransactionStore.isCreatingMode()) {
      this.createExpenseTransaction($event);
    } else {
      this.updateExpenseTransaction($event);
    }
  }

  protected async submitIncomeForm($event: IncomeFormData) {
    if (this.selectedTransactionStore.isCreatingMode()) {
      this.createIncomeTransaction($event);
    } else {
      this.updateIncomeTransaction($event);
    }
  }

  protected async createGroup(name: string, transactionType: TransactionType) {
    const { error } = await this.categoriesStore.createGroup(
      name,
      transactionType,
    );

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: this.t('transactions.groupCreationFailed'),
        detail: error.message,
      });
    } else {
      this.messageService.add({
        severity: 'success',
        summary: 'Group created successfully',
      });
    }
  }

  protected async createCategory(name: string, groupId: number) {
    const { error } = await this.categoriesStore.createCategory(name, groupId);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Category creation failed',
        detail: error.message,
      });
    } else {
      this.messageService.add({
        severity: 'success',
        summary: 'Category created successfully',
      });
    }
  }

  private defineMode() {
    this.selectedTransactionStore.updateIsCreatingMode(
      this.route.snapshot.url[0].path === 'create',
    );
  }

  private async createExpenseTransaction(
    formData: ExpenseFormData,
  ): Promise<void> {
    const { error } =
      await this.expenseTransactionStore.createTransaction(formData);
    await this.transactionsStore.loadTransactions();

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Transaction creation failed',
        detail: error.message,
      });
    } else {
      this.transactionsStore.markAsNotLoaded();
      this.goBack();
    }
  }

  private async createIncomeTransaction(
    formData: IncomeFormData,
  ): Promise<void> {
    const { error } =
      await this.incomeTransactionStore.createTransaction(formData);
    await this.transactionsStore.loadTransactions();

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Transaction creation failed',
        detail: error.message,
      });
    } else {
      this.transactionsStore.markAsNotLoaded();
      this.goBack();
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

  private async updateIncomeTransaction(
    formData: IncomeFormData,
  ): Promise<void> {
    const { error } =
      await this.incomeTransactionStore.updateTransaction(formData);

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

  protected async deleteTransaction(): Promise<void> {
    const { error } = await this.selectedTransactionStore.deleteTransaction();
    await this.transactionsStore.loadTransactions();

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Transaction deletion failed',
        detail: error.message,
      });
    } else {
      this.transactionsStore.markAsNotLoaded();
      this.goBack();
    }
  }

  private goBack() {
    this.router.navigate(['..'], { relativeTo: this.route });
  }
}
