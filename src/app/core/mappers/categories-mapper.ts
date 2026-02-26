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
      groupId: dto.groups.id,
      groupName: dto.groups.name,
    };
  }
}
