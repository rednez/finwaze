export type TransactionType = 'income' | 'expense' | 'transfer';

export interface Transaction {
  id: number;
  account: { id: number; name: string };
  transactedAt: Date;
  localOffset: string;
  transactionAmount: number;
  transactionCurrency: string;
  chargedAmount: number;
  chargedCurrency: string;
  exchangeRate: number;
  type: TransactionType;
  group: { id: number; name: string };
  category: { id: number; name: string };
  comment: string | null;
  transferId: string | null;
}
