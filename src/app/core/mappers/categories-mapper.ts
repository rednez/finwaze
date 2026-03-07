import { Injectable } from '@angular/core';
import { Category } from '@core/models/categories';

@Injectable({
  providedIn: 'root',
})
export class CategoriesMapper {
  fromCategoryDto(dto: any): Category {
    return {
      id: dto.id,
      name: dto.name,
      group: {
        id: dto.groups.id,
        name: dto.groups.name,
        transactionType: dto.groups.transaction_type,
      },
    };
  }
}
