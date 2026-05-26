import { TransactionType } from './transactions';

export interface GroupDto {
  id: number;
  name: string;
  transaction_type: TransactionType;
  color?: string | null;
}

export interface CategoryDto {
  id: number;
  name: string;
  group_id: number;
  color?: string | null;
}

export interface Group {
  id: number;
  name: string;
  transactionType: TransactionType;
  color?: string | null;
}

export interface Category {
  id: number;
  name: string;
  groupId: number;
  color?: string | null;
}
