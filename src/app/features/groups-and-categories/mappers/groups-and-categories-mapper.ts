import { Injectable } from '@angular/core';
import { CategoryWithTxCount, GroupWithCategories } from '../models';
import { TransactionType } from '@core/models/transactions';

@Injectable({
  providedIn: 'root',
})
export class GroupsAndCategoriesMapper {
  fromGroupWithCategoriesDto = (dto: {
    id: number;
    name: string;
    transaction_type: TransactionType;
    categories: {
      id: number;
      name: string;
      transactions_count: number;
    }[];
  }): GroupWithCategories => {
    return {
      id: dto.id,
      name: dto.name,
      transactionType: dto.transaction_type,
      categories: dto.categories.map(this.fromCategoryWithTxCountDto),
    };
  };

  private fromCategoryWithTxCountDto = (dto: {
    id: number;
    name: string;
    transactions_count: number;
  }): CategoryWithTxCount => {
    return {
      id: dto.id,
      name: dto.name,
      transactionsCount: dto.transactions_count,
    };
  };
}
