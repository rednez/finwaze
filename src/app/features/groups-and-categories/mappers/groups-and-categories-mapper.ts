import { Injectable } from '@angular/core';
import { CategoryWithTxCount, GroupWithCategories } from '../models';

@Injectable({
  providedIn: 'root',
})
export class GroupsAndCategoriesMapper {
  fromGroupWithCategoriesDto = (dto: any): GroupWithCategories => {
    return {
      id: dto.id,
      name: dto.name,
      transactionType: dto.transaction_type,
      categories: dto.categories.map(this.fromCategoryWithTxCountDto),
    };
  };

  private fromCategoryWithTxCountDto = (dto: any): CategoryWithTxCount => {
    return {
      id: dto.id,
      name: dto.name,
      transactionsCount: dto.transactions_count,
    };
  };
}
