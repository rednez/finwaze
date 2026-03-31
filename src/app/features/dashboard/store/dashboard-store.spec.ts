import { signal } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { AccountsStore } from '@core/store/accounts-store';
import { Transaction } from '@core/models/transactions';
import {
  MonthlyCashFlow,
  RecentMonthlyBudget,
  RecentSavingsGoal,
  TotalSummaries,
} from '../models';
import { DashboardRepository } from '../repositories';
import { DashboardLoadingStateStore } from './dashboard-loading-state-store';
import { DashboardStore } from './dashboard-store';

const totalsSummary: TotalSummaries = {
  totalBalance: 10000,
  monthlyIncome: 3000,
  monthlyExpense: 2000,
  previousMonthTotalBalance: 9000,
  previousMonthlyIncome: 2800,
  previousMonthlyExpense: 1800,
};

const cashFlow: MonthlyCashFlow[] = [
  { month: new Date('2026-01-01'), income: 3000, expense: 2500 },
  { month: new Date('2026-02-01'), income: 3200, expense: 2100 },
];

const recentTransactions: Transaction[] = [
  {
    id: 1,
    account: { id: 1, name: 'Main' },
    transactedAt: new Date('2026-03-15'),
    localOffset: '+02:00',
    transactionAmount: 50,
    transactionCurrency: 'USD',
    chargedAmount: 50,
    chargedCurrency: 'USD',
    exchangeRate: 1,
    type: 'expense',
    group: { id: 1, name: 'Food' },
    category: { id: 1, name: 'Groceries' },
    comment: null,
    transferId: null,
  },
];

const recentGoals: RecentSavingsGoal[] = [
  {
    id: 1,
    name: 'Vacation',
    targetAmount: 5000,
    currentAmount: 1500,
    currency: 'USD',
  },
];

const recentBudgets: RecentMonthlyBudget[] = [
  { name: 'Groceries', amount: 300 },
];

function setup(
  overrides: {
    repository?: Partial<DashboardRepository>;
    accountsStore?: Partial<InstanceType<typeof AccountsStore>>;
    loadingStore?: Partial<InstanceType<typeof DashboardLoadingStateStore>>;
  } = {},
) {
  const repository: Partial<DashboardRepository> = {
    getTotals: vi.fn().mockResolvedValue(totalsSummary),
    getMonthlyCashFlow: vi.fn().mockResolvedValue(cashFlow),
    getRecentTransactions: vi.fn().mockResolvedValue(recentTransactions),
    getRecentSavingsGoals: vi.fn().mockResolvedValue(recentGoals),
    getRecentMonthlyBudgets: vi.fn().mockResolvedValue(recentBudgets),
    ...overrides.repository,
  };

  const accountsStore = {
    selectedCurrencyCode: signal<string | undefined>('USD'),
    myCurrencies: signal(['USD', 'EUR']),
    isLoading: signal(false),
    ...overrides.accountsStore,
  };

  const loadingStore = {
    isLoading: signal(false),
    isLoaded: signal(false),
    isError: signal(false),
    isUpdating: signal(false),
    startLoading: vi.fn(),
    successLoading: vi.fn(),
    errorLoading: vi.fn(),
    startUpdating: vi.fn(),
    successUpdating: vi.fn(),
    errorUpdating: vi.fn(),
    ...overrides.loadingStore,
  };

  TestBed.configureTestingModule({
    providers: [
      DashboardStore,
      { provide: DashboardRepository, useValue: repository },
      { provide: AccountsStore, useValue: accountsStore },
      { provide: DashboardLoadingStateStore, useValue: loadingStore },
    ],
  });

  return {
    store: TestBed.inject(DashboardStore),
    repository: repository as DashboardRepository,
    loadingStore,
  };
}

describe('DashboardStore', () => {
  describe('initial state', () => {
    it('has empty totals summary', () => {
      const { store } = setup();

      expect(store.totalsSummary()).toEqual({
        totalBalance: 0,
        monthlyIncome: 0,
        monthlyExpense: 0,
        previousMonthTotalBalance: 0,
        previousMonthlyIncome: 0,
        previousMonthlyExpense: 0,
      });
    });

    it('has empty collections', () => {
      const { store } = setup();

      expect(store.recentTransactions()).toEqual([]);
      expect(store.recentSavingsGoals()).toEqual([]);
      expect(store.recentMonthlyBudgets()).toEqual([]);
    });
  });

  describe('computed: displayedTotalsSummary', () => {
    it('returns three summary cards from totals', async () => {
      const { store } = setup();
      await store.loadTotalsSummary();

      const cards = store.displayedTotalsSummary();

      expect(cards).toEqual([
        {
          title: 'Total balance',
          amount: 10000,
          previousAmount: 9000,
          growTrendIsGood: true,
        },
        {
          title: 'Income',
          amount: 3000,
          previousAmount: 2800,
          growTrendIsGood: true,
        },
        {
          title: 'Expenses',
          amount: 2000,
          previousAmount: 1800,
          growTrendIsGood: false,
        },
      ]);
    });
  });

  describe('computed: cashFlow projections', () => {
    it('extracts months, incomes, and expenses from cash flow data', async () => {
      const { store } = setup();
      await store.loadCashFlow();

      expect(store.cashFlowMonths()).toEqual([
        new Date('2026-01-01'),
        new Date('2026-02-01'),
      ]);
      expect(store.cashFlowIncomes()).toEqual([3000, 3200]);
      expect(store.cashFlowExpenses()).toEqual([2500, 2100]);
    });
  });

  describe('computed: delegated signals', () => {
    it('delegates isLoading to loadingStore or accountsStore', () => {
      const { store } = setup({
        loadingStore: { isLoading: signal(true) },
      });

      expect(store.isLoading()).toBe(true);
    });

    it('returns true when accountsStore is loading', () => {
      const { store } = setup({
        accountsStore: { isLoading: signal(true) },
      });

      expect(store.isLoading()).toBe(true);
    });

    it('delegates isError to loadingStore', () => {
      const { store } = setup({
        loadingStore: { isError: signal(true) },
      });

      expect(store.isError()).toBe(true);
    });

    it('delegates myCurrencies to accountsStore', () => {
      const { store } = setup();

      expect(store.myCurrencies()).toEqual(['USD', 'EUR']);
    });

    it('delegates selectedCurrencyCode to accountsStore', () => {
      const { store } = setup();

      expect(store.selectedCurrencyCode()).toBe('USD');
    });
  });

  describe('loadTotalsSummary', () => {
    it('fetches totals and patches state', async () => {
      const { store, repository } = setup();

      await store.loadTotalsSummary();

      expect(repository.getTotals).toHaveBeenCalledWith('USD');
      expect(store.totalsSummary()).toEqual(totalsSummary);
    });

    it('starts loading and signals success', async () => {
      const { store, loadingStore } = setup();

      await store.loadTotalsSummary();

      expect(loadingStore.startLoading).toHaveBeenCalled();
      expect(loadingStore.successLoading).toHaveBeenCalled();
    });

    it('uses updating flow when already loaded', async () => {
      const { store, loadingStore } = setup({
        loadingStore: { isLoaded: signal(true) },
      });

      await store.loadTotalsSummary();

      expect(loadingStore.startUpdating).toHaveBeenCalled();
      expect(loadingStore.successUpdating).toHaveBeenCalled();
    });

    it('signals error on repository failure', async () => {
      const { store, loadingStore } = setup({
        repository: {
          getTotals: vi.fn().mockRejectedValue(new Error('fail')),
        },
      });

      await store.loadTotalsSummary();

      expect(loadingStore.errorLoading).toHaveBeenCalled();
    });

    it('signals error when currency is not set', async () => {
      const { store, loadingStore } = setup({
        accountsStore: { selectedCurrencyCode: signal(undefined) },
      });

      await store.loadTotalsSummary();

      expect(loadingStore.errorLoading).toHaveBeenCalled();
    });
  });

  describe('loadCashFlow', () => {
    it('fetches cash flow with 12 months and patches state', async () => {
      const { store, repository } = setup();

      await store.loadCashFlow();

      expect(repository.getMonthlyCashFlow).toHaveBeenCalledWith('USD', 12);
      expect(store.cashFlowMonths()).toEqual(cashFlow.map((i) => i.month));
    });

    it('signals error on failure', async () => {
      const { store, loadingStore } = setup({
        repository: {
          getMonthlyCashFlow: vi.fn().mockRejectedValue(new Error('fail')),
        },
      });

      await store.loadCashFlow();

      expect(loadingStore.errorLoading).toHaveBeenCalled();
    });

    it('signals error when currency is not set', async () => {
      const { store, loadingStore } = setup({
        accountsStore: { selectedCurrencyCode: signal(undefined) },
      });

      await store.loadCashFlow();

      expect(loadingStore.errorLoading).toHaveBeenCalled();
    });
  });

  describe('loadRecentTransactions', () => {
    it('fetches recent transactions and patches state', async () => {
      const { store, repository } = setup();

      await store.loadRecentTransactions();

      expect(repository.getRecentTransactions).toHaveBeenCalled();
      expect(store.recentTransactions()).toEqual(recentTransactions);
    });

    it('signals error on failure', async () => {
      const { store, loadingStore } = setup({
        repository: {
          getRecentTransactions: vi.fn().mockRejectedValue(new Error('fail')),
        },
      });

      await store.loadRecentTransactions();

      expect(loadingStore.errorLoading).toHaveBeenCalled();
    });
  });

  describe('loadRecentSavingsGoals', () => {
    it('fetches recent goals and patches state', async () => {
      const { store, repository } = setup();

      await store.loadRecentSavingsGoals();

      expect(repository.getRecentSavingsGoals).toHaveBeenCalled();
      expect(store.recentSavingsGoals()).toEqual(recentGoals);
    });

    it('signals error on failure', async () => {
      const { store, loadingStore } = setup({
        repository: {
          getRecentSavingsGoals: vi.fn().mockRejectedValue(new Error('fail')),
        },
      });

      await store.loadRecentSavingsGoals();

      expect(loadingStore.errorLoading).toHaveBeenCalled();
    });
  });

  describe('loadRecentMonthlyBudgets', () => {
    it('fetches recent budgets and patches state', async () => {
      const { store, repository } = setup();

      await store.loadRecentMonthlyBudgets();

      expect(repository.getRecentMonthlyBudgets).toHaveBeenCalledWith('USD');
      expect(store.recentMonthlyBudgets()).toEqual(recentBudgets);
    });

    it('signals error on failure', async () => {
      const { store, loadingStore } = setup({
        repository: {
          getRecentMonthlyBudgets: vi.fn().mockRejectedValue(new Error('fail')),
        },
      });

      await store.loadRecentMonthlyBudgets();

      expect(loadingStore.errorLoading).toHaveBeenCalled();
    });

    it('signals error when currency is not set', async () => {
      const { store, loadingStore } = setup({
        accountsStore: { selectedCurrencyCode: signal(undefined) },
      });

      await store.loadRecentMonthlyBudgets();

      expect(loadingStore.errorLoading).toHaveBeenCalled();
    });
  });
});
