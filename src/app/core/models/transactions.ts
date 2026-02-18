export type TransactionType = 'income' | 'expense';

export interface Transaction {
  id: number;
  accountName: string;
  transactedAt: Date;
  transactionAmount: number;
  transactionCurrency: string;
  chargedAmount: number;
  chargedCurrency: string;
  exchangeRate: number;
  type: TransactionType;
  groupName: string;
  categoryName: string;
  comment: string | null;
}
