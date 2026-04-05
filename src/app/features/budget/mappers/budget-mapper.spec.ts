import { TestBed } from '@angular/core/testing';

import { MonthlyBudgetDetailedDto } from '../models';
import { BudgetMapper } from './budget-mapper';

function makeDto(
  overrides: Partial<MonthlyBudgetDetailedDto> = {},
): MonthlyBudgetDetailedDto {
  return {
    category_id: 1,
    category_name: 'Category',
    group_id: 10,
    group_name: 'Group',
    planned_amount: 100,
    previous_planned_amount: 80,
    spent_amount: 50,
    previous_spent_amount: 40,
    is_unplanned: false,
    ...overrides,
  };
}

describe('BudgetMapper', () => {
  let mapper: BudgetMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    mapper = TestBed.inject(BudgetMapper);
  });

  it('should be created', () => {
    expect(mapper).toBeTruthy();
  });

  describe('fromDetailedBudgetDtosToGroupRows', () => {
    it('includes all rows regardless of previous activity', () => {
      const dtos = [
        makeDto({
          category_id: 1,
          previous_planned_amount: 0,
          spent_amount: 0,
        }),
        makeDto({
          category_id: 2,
          previous_planned_amount: 0,
          spent_amount: 0,
        }),
      ];
      const result = mapper.fromDetailedBudgetDtosToGroupRows(dtos);
      expect(result[0].categories.length).toBe(2);
    });

    it('uses planned_amount as plannedAmount', () => {
      const dto = makeDto({ planned_amount: 200, previous_planned_amount: 80 });
      const result = mapper.fromDetailedBudgetDtosToGroupRows([dto]);
      expect(result[0].categories[0].plannedAmount).toBe(200);
    });

    describe('tempId uniqueness', () => {
      it('assigns unique tempIds to all categories and groups', () => {
        const dtos = [
          makeDto({ group_id: 10, category_id: 1 }),
          makeDto({ group_id: 10, category_id: 2 }),
          makeDto({ group_id: 20, category_id: 3 }),
        ];
        const result = mapper.fromDetailedBudgetDtosToGroupRows(dtos);
        const allIds = [
          ...result.map((g) => g.tempId),
          ...result.flatMap((g) => g.categories.map((c) => c.tempId)),
        ];
        const unique = new Set(allIds);
        expect(unique.size).toBe(allIds.length);
      });
    });
  });
});
