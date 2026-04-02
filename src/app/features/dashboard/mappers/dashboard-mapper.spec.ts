import { TestBed } from '@angular/core/testing';

import { DashboardMapper } from './dashboard-mapper';

describe('DashboardMapper', () => {
  let mapper: DashboardMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    mapper = TestBed.inject(DashboardMapper);
  });

  it('should be created', () => {
    expect(mapper).toBeTruthy();
  });

  describe('fromTotalsSummaryDto', () => {
    it('maps all fields from dto', () => {
      const result = mapper.fromTotalsSummaryDto({
        total_balance: 1000,
        monthly_income: 500,
        monthly_expense: 300,
        previous_total_balance: 900,
        previous_monthly_income: 450,
        previous_monthly_expense: 250,
      });

      expect(result).toEqual({
        totalBalance: 1000,
        monthlyIncome: 500,
        monthlyExpense: 300,
        previousMonthTotalBalance: 900,
        previousMonthlyIncome: 450,
        previousMonthlyExpense: 250,
      });
    });

    it('defaults missing fields to 0', () => {
      const result = mapper.fromTotalsSummaryDto({});

      expect(result).toEqual({
        totalBalance: 0,
        monthlyIncome: 0,
        monthlyExpense: 0,
        previousMonthTotalBalance: 0,
        previousMonthlyIncome: 0,
        previousMonthlyExpense: 0,
      });
    });
  });

  describe('fromMonthlyCashFlowDto', () => {
    it('maps month to Date and income/expense from dto', () => {
      const result = mapper.fromMonthlyCashFlowDto({
        month: '2026-03-01',
        total_income: 1200,
        total_expense: -800,
      });

      expect(result.month).toEqual(new Date('2026-03-01'));
      expect(result.income).toBe(1200);
      expect(result.expense).toBe(800);
    });

    it('defaults missing income and expense to 0', () => {
      const result = mapper.fromMonthlyCashFlowDto({ month: '2026-01-01' });

      expect(result.income).toBe(0);
      expect(result.expense).toBe(0);
    });

    it('converts negative expense to positive via Math.abs', () => {
      const result = mapper.fromMonthlyCashFlowDto({
        month: '2026-02-01',
        total_expense: -450,
      });

      expect(result.expense).toBe(450);
    });

    it('keeps positive expense as-is', () => {
      const result = mapper.fromMonthlyCashFlowDto({
        month: '2026-02-01',
        total_expense: 450,
      });

      expect(result.expense).toBe(450);
    });

    it('treats zero expense as falsy and defaults to 0', () => {
      const result = mapper.fromMonthlyCashFlowDto({
        month: '2026-02-01',
        total_expense: 0,
      });

      expect(result.expense).toBe(0);
    });
  });

  describe('fromRecentMonthlyBudgetDto', () => {
    it('maps category_name to name and total_budget to amount', () => {
      const result = mapper.fromRecentMonthlyBudgetDto({
        category_name: 'Groceries',
        total_budget: 250,
      });

      expect(result).toEqual({
        name: 'Groceries',
        amount: 250,
      });
    });
  });
});
