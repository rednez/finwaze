import { Category } from '@core/models/categories';

export interface CategoryWithTxCount extends Omit<Category, 'groupId'> {
  transactionsCount: number;
}
