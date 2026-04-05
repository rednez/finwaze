import { TestBed } from '@angular/core/testing';
import { MonthlyBudgetDetailedDto } from '../../models';
import { BudgetMapper } from '../../mappers';
import { BudgetRepository } from '../../repositories';
import { BudgetStore } from '../../stores';
import { CreateBudgetStore } from './create-budget-store';

function makeDto(
  overrides: Partial<MonthlyBudgetDetailedDto> = {},
): MonthlyBudgetDetailedDto {
  return {
    category_id: 1,
    category_name: 'Food',
    group_id: 10,
    group_name: 'Living',
    planned_amount: 100,
    previous_planned_amount: 80,
    spent_amount: 50,
    previous_spent_amount: 40,
    is_unplanned: false,
    ...overrides,
  };
}

function setup(repositoryOverrides: Partial<BudgetRepository> = {}) {
  const repository: Partial<BudgetRepository> = {
    getDetailedMonthlyBudgets: vi.fn().mockResolvedValue([]),
    generateBudgetsFromPrevious: vi.fn().mockResolvedValue([]),
    upsertMonthlyBudgets: vi.fn().mockResolvedValue(undefined),
    getCategoryBudgetStats: vi.fn().mockResolvedValue({
      prevPlannedAmount: 0,
      currentSpentAmount: 0,
      prevSpentAmount: 0,
    }),
    ...repositoryOverrides,
  };

  const budgetStore = {
    month: () => new Date('2026-03-01'),
    currencyCode: () => 'USD',
  };

  TestBed.configureTestingModule({
    providers: [
      CreateBudgetStore,
      { provide: BudgetRepository, useValue: repository },
      { provide: BudgetStore, useValue: budgetStore },
      BudgetMapper,
    ],
  });

  return {
    store: TestBed.inject(CreateBudgetStore),
    repository: repository as BudgetRepository,
  };
}

describe('CreateBudgetStore', () => {
  describe('loadExistingBudget', () => {
    it('sets budgetExists=true and populates groups when rows with planned_amount > 0 exist', async () => {
      const dto = makeDto({ planned_amount: 100 });
      const { store } = setup({
        getDetailedMonthlyBudgets: vi.fn().mockResolvedValue([dto]),
      });

      const result = await TestBed.runInInjectionContext(() =>
        store.loadExistingBudget('2026-03-01', 'USD'),
      );

      expect(result.ok).toBe(true);
      expect(store.budgetExists()).toBe(true);
      expect(store.groups().length).toBeGreaterThan(0);
    });

    it('leaves budgetExists=false when no rows have planned_amount > 0', async () => {
      const dto = makeDto({ planned_amount: 0 });
      const { store } = setup({
        getDetailedMonthlyBudgets: vi.fn().mockResolvedValue([dto]),
      });

      const result = await TestBed.runInInjectionContext(() =>
        store.loadExistingBudget('2026-03-01', 'USD'),
      );

      expect(result.ok).toBe(true);
      expect(store.budgetExists()).toBe(false);
    });

    it('returns resultError and resets isLoading on repository failure', async () => {
      const { store } = setup({
        getDetailedMonthlyBudgets: vi
          .fn()
          .mockRejectedValue(new Error('Load failed')),
      });

      const result = await TestBed.runInInjectionContext(() =>
        store.loadExistingBudget('2026-03-01', 'USD'),
      );

      expect(result.ok).toBe(false);
      expect(store.isLoading()).toBe(false);
    });
  });

  describe('generateFromPreviousMonth', () => {
    it('populates groups via mapper', async () => {
      const dto = makeDto({
        planned_amount: 80,
        previous_planned_amount: 80,
        spent_amount: 0,
      });
      const { store } = setup({
        generateBudgetsFromPrevious: vi.fn().mockResolvedValue([dto]),
      });

      const result = await TestBed.runInInjectionContext(() =>
        store.generateFromPreviousMonth('2026-03-01', 'USD'),
      );

      expect(result.ok).toBe(true);
      expect(store.budgetExists()).toBe(true);
      expect(store.groups().length).toBeGreaterThan(0);
      expect(store.groups()[0].categories[0].plannedAmount).toBe(
        dto.planned_amount,
      );
    });
  });

  describe('saveBudget', () => {
    it('calls upsertMonthlyBudgets with flattened categories', async () => {
      const { store, repository } = setup();
      store.startManual();
      store.addGroup(10);
      const groupTempId = store.groups()[0].tempId;
      store.addCategory(groupTempId, 1);
      store.updateCategoryPlanned(
        groupTempId,
        store.groups()[0].categories[0].tempId,
        200,
      );

      await TestBed.runInInjectionContext(() =>
        store.saveBudget('2026-03-01', 'USD'),
      );

      expect(repository.upsertMonthlyBudgets).toHaveBeenCalledWith({
        month: '2026-03-01',
        currencyCode: 'USD',
        categories: [{ category_id: 1, planned_amount: 200 }],
      });
    });

    it('returns resultError on repository failure', async () => {
      const { store } = setup({
        upsertMonthlyBudgets: vi
          .fn()
          .mockRejectedValue(new Error('Save failed')),
      });

      const result = await TestBed.runInInjectionContext(() =>
        store.saveBudget('2026-03-01', 'USD'),
      );

      expect(result.ok).toBe(false);
      expect(store.isSaving()).toBe(false);
    });
  });
});
