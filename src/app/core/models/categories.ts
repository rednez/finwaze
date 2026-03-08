import { TransactionType } from './transactions';

export interface Group {
  id: number;
  name: string;
  transactionType: TransactionType;
}

export interface Category {
  id: number;
  name: string;
  groupId: number;
}
