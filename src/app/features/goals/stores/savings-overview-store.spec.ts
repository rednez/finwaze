import { TestBed } from '@angular/core/testing';
import {
  GoalsRepository,
  MonthlySavingsOverview,
} from '../repositories/goals-repository';
import { SavingsOverviewStore } from './savings-overview-store';

const mockData: MonthlySavingsOverview[] = Array.from(
  { length: 12 },
  (_, i) => ({
    month: `2026-${String(i + 1).padStart(2, '0')}-01`,
    currentYearAmount: 1000 * (i + 1),
    previousYearAmount: 800 * (i + 1),
  }),
);

function setup(repositoryOverrides: Partial<GoalsRepository> = {}) {
  const repository: Partial<GoalsRepository> = {
    getGoals: vi.fn().mockResolvedValue([]),
    getSavingsOverview: vi.fn().mockResolvedValue(mockData),
    ...repositoryOverrides,
  };

  TestBed.configureTestingModule({
    providers: [
      SavingsOverviewStore,
      { provide: GoalsRepository, useValue: repository },
    ],
  });

  return {
    store: TestBed.inject(SavingsOverviewStore),
    repository: repository as GoalsRepository,
  };
}

describe('SavingsOverviewStore', () => {
  describe('initial state', () => {
    it('starts with empty data and not loaded', () => {
      const { store } = setup();
      expect(store.data()).toEqual([]);
      expect(store.isLoaded()).toBe(false);
    });
  });

  describe('load()', () => {
    it('calls repository with current year and currency', async () => {
      const { store, repository } = setup();
      const year = new Date('2026-01-01');
      store.updateYear(year);
      store.updateCurrencyCode('EUR');

      await store.load();

      expect(repository.getSavingsOverview).toHaveBeenCalledWith({
        year,
        currencyCode: 'EUR',
      });
    });

    it('populates data and sets isLoaded on success', async () => {
      const { store } = setup();
      store.updateCurrencyCode('USD');
      await store.load();

      expect(store.data()).toEqual(mockData);
      expect(store.isLoaded()).toBe(true);
      expect(store.isLoading()).toBe(false);
      expect(store.isError()).toBe(false);
    });

    it('sets isError on failure', async () => {
      const { store } = setup({
        getSavingsOverview: vi.fn().mockRejectedValue(new Error('db error')),
      });

      store.updateCurrencyCode('USD');
      await store.load();

      expect(store.isError()).toBe(true);
      expect(store.isLoading()).toBe(false);
    });
  });

  describe('computed signals', () => {
    it('labels returns month strings', async () => {
      const { store } = setup();
      store.updateCurrencyCode('USD');
      await store.load();
      expect(store.labels()).toEqual(mockData.map((r) => r.month));
    });

    it('currentSavings returns current year amounts', async () => {
      const { store } = setup();
      store.updateCurrencyCode('USD');
      await store.load();
      expect(store.currentSavings()).toEqual(
        mockData.map((r) => r.currentYearAmount),
      );
    });

    it('previousSavings returns previous year amounts', async () => {
      const { store } = setup();
      store.updateCurrencyCode('USD');
      await store.load();
      expect(store.previousSavings()).toEqual(
        mockData.map((r) => r.previousYearAmount),
      );
    });
  });

  describe('updateYear / updateCurrencyCode', () => {
    it('updateYear patches selectedYear', () => {
      const { store } = setup();
      const d = new Date('2025-01-01');
      store.updateYear(d);
      expect(store.selectedYear()).toEqual(d);
    });

    it('updateCurrencyCode patches selectedCurrencyCode', () => {
      const { store } = setup();
      store.updateCurrencyCode('UAH');
      expect(store.selectedCurrencyCode()).toBe('UAH');
    });
  });
});
