export interface UiExpenseTransactionForm {
  accountId: number | null;
  groupId: number | null;
  categoryId: number | null;
  transactionCurrencyCode: string | null;
  chargedCurrencyCode: string | null;
}

export interface UiIncomeTransactionForm {
  accountId: number | null;
  groupId: number | null;
  categoryId: number | null;
}

export interface UiState {
  expenseTransactionForm: UiExpenseTransactionForm;
  incomeTransactionForm: UiIncomeTransactionForm;
}
