import { Injectable } from '@angular/core';
import { Category, Group } from '@core/models/categories';

@Injectable({
  providedIn: 'root',
})
export class CategoriesMapper {
  fromGroupDto(dto: any): Group {
    return {
      id: dto.id,
      name: dto.name,
      transactionType: dto.transaction_type,
    };
  }

  fromCategoryDto(dto: any): Category {
    return {
      id: dto.id,
      name: dto.name,
      groupId: dto.group_id,
    };
  }
}
