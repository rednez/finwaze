export interface Transaction {
  id: number;
  date: string;
  group: string;
  category: string;
  transactionAmount: number;
  transactionCurrency: string;
  chargedAmount: number;
  chargedCurrency: string;
  exchangeRate: number;
  description: string | null;
  isIncome: boolean;
}
