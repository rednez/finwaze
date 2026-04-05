import { TestBed } from '@angular/core/testing';

import { CategoryDto, GroupDto } from '@core/models/categories';
import { CategoriesMapper } from './categories-mapper';

describe('CategoriesMapper', () => {
  let mapper: CategoriesMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    mapper = TestBed.inject(CategoriesMapper);
  });

  it('should be created', () => {
    expect(mapper).toBeTruthy();
  });

  describe('fromGroupDto', () => {
    it('maps dto fields to Group model', () => {
      const dto: GroupDto = {
        id: 10,
        name: 'Transport',
        transaction_type: 'expense',
      };

      expect(mapper.fromGroupDto(dto)).toEqual({
        id: 10,
        name: 'Transport',
        transactionType: 'expense',
      });
    });

    it('preserves income transaction type', () => {
      const dto: GroupDto = {
        id: 5,
        name: 'Salary',
        transaction_type: 'income',
      };

      expect(mapper.fromGroupDto(dto).transactionType).toBe('income');
    });
  });

  describe('fromCategoryDto', () => {
    it('maps dto fields to Category model', () => {
      const dto: CategoryDto = {
        id: 3,
        name: 'Fuel',
        group_id: 10,
      };

      expect(mapper.fromCategoryDto(dto)).toEqual({
        id: 3,
        name: 'Fuel',
        groupId: 10,
      });
    });
  });
});
