export interface ExpenseFormData {
  accountId: number;
  groupId: number;
  categoryId: number;
  transactedAt: Date;
  comment: string;
  transactionAmount: number;
  transactionCurrencyCode: string;
  chargedAmount: number;
}

export interface IncomeFormData {
  accountId: number;
  groupId: number;
  categoryId: number;
  transactedAt: Date;
  comment: string;
  amount: number;
  currencyCode: string;
}
