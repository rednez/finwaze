import { TestBed } from '@angular/core/testing';

import { GroupsAndCategoriesMapper } from './groups-and-categories-mapper';

describe('GroupsAndCategoriesMapper', () => {
  let mapper: GroupsAndCategoriesMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    mapper = TestBed.inject(GroupsAndCategoriesMapper);
  });

  it('should be created', () => {
    expect(mapper).toBeTruthy();
  });

  describe('fromGroupWithCategoriesDto', () => {
    it('maps group fields and categories', () => {
      const result = mapper.fromGroupWithCategoriesDto({
        id: 10,
        name: 'Transport',
        transaction_type: 'expense',
        categories: [
          { id: 1, name: 'Fuel', transactions_count: 25 },
          { id: 2, name: 'Parking', transactions_count: 8 },
        ],
      });

      expect(result).toEqual({
        id: 10,
        name: 'Transport',
        transactionType: 'expense',
        categories: [
          { id: 1, name: 'Fuel', transactionsCount: 25 },
          { id: 2, name: 'Parking', transactionsCount: 8 },
        ],
      });
    });

    it('maps transaction_type to transactionType', () => {
      const result = mapper.fromGroupWithCategoriesDto({
        id: 5,
        name: 'Salary',
        transaction_type: 'income',
        categories: [],
      });

      expect(result.transactionType).toBe('income');
    });

    it('returns empty categories array when dto has none', () => {
      const result = mapper.fromGroupWithCategoriesDto({
        id: 1,
        name: 'Empty Group',
        transaction_type: 'expense',
        categories: [],
      });

      expect(result.categories).toEqual([]);
    });

    it('maps transactions_count to transactionsCount for each category', () => {
      const result = mapper.fromGroupWithCategoriesDto({
        id: 1,
        name: 'Food',
        transaction_type: 'expense',
        categories: [{ id: 3, name: 'Groceries', transactions_count: 42 }],
      });

      expect(result.categories[0].transactionsCount).toBe(42);
    });
  });
});
