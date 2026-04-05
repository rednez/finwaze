import { TransactionType } from './transactions';

export interface GroupDto {
  id: number;
  name: string;
  transaction_type: TransactionType;
}

export interface CategoryDto {
  id: number;
  name: string;
  group_id: number;
}

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
