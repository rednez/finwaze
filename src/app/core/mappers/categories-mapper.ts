import { Injectable } from '@angular/core';
import {
  Category,
  CategoryDto,
  Group,
  GroupDto,
} from '@core/models/categories';

@Injectable({
  providedIn: 'root',
})
export class CategoriesMapper {
  fromGroupDto(dto: GroupDto): Group {
    return {
      id: dto.id,
      name: dto.name,
      transactionType: dto.transaction_type,
    };
  }

  fromCategoryDto(dto: CategoryDto): Category {
    return {
      id: dto.id,
      name: dto.name,
      groupId: dto.group_id,
    };
  }
}
