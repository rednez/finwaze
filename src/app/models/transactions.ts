export type TransactionType = 'income' | 'expense';

export interface Transaction {
  id: number;
  createdAt: Date;
  // budgetMonth: Date;
  group: string;
  category: string;
  transactionAmount: number;
  transactionCurrency: string;
  chargedAmount: number;
  chargedCurrency: string;
  exchangeRate: number;
  comment: string | null;
  type: TransactionType;
  // isDeleted: boolean;
}
