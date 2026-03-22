export type TransactionType = 'income' | 'expense' | 'transfer';

export interface TransactionDto {
  id: number;
  transacted_at: string;
  local_offset: string;
  transaction_amount: number;
  transaction_currency_code: string;
  account_id: number;
  account_name: string;
  charged_amount: number;
  charged_currency_code: string;
  exchange_rate: number;
  type: TransactionType;
  category_id: number;
  category_name: string;
  group_id: number;
  group_name: string;
  comment: string;
  transfer_id: string;
}

export interface TransactionDetailsDto {
  id: number;
  transacted_at: string;
  local_offset: string;
  transaction_amount: number;
  charged_amount: number;
  type: TransactionType;
  comment: string;
  account: { id: number; name: string };
  transaction_currency: { code: string };
  charged_currency: { code: string };
  category: { id: number; name: string; group: { id: number; name: string } };
  transfer_id: string;
}

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
