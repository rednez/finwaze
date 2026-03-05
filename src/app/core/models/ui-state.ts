export interface UiExpenseTransactionForm {
  accountId: number | null;
  groupId: number | null;
  categoryId: number | null;
  transactionCurrencyCode: string | null;
  chargedCurrencyCode: string | null;
}

export interface UiState {
  expenseTransactionForm: UiExpenseTransactionForm;
}
